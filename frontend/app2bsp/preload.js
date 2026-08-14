#!/usr/bin/env node

// Builds the UI5 component preload bundle and drops it into the webapp, so
// that the next step (run.js) turns it into a BSP page like every other file.
// Run it from the same working directory as run.js, before run.js:
//
//     node .github/app2bsp/preload.js
//     node .github/app2bsp/run.js
//
// Why: UI5 asks for `<component>/Component-preload.js` on every component
// start. The BSP had no such file, so the request answered 404 ("failed to
// load JavaScript resource: z2ui5/Component-preload.js") and UI5 fell back to
// fetching every module on its own - around 50 round trips per app start.
//
// The bundle canNOT be delivered under that conventional name: a BSP page name
// must not contain a hyphen, and CL_O2_API_PAGES=>CREATE_NEW_PAGE rejects it
// with sy-subrc=2 (invalid_name), which fails the whole WAPA import. (Standard
// Fiori apps carry Component-preload.js as a MIME object, not as a BSP page -
// that is why the name works there.) So the bundle ships as `preload.js` and
// index.html points the bootstrap at it via `data-sap-ui-oninit`, the same
// mechanism the ABAP-only variant uses (z2ui5_cl_ui5_http_handler).
//
// That also removes the 404 rather than just avoiding a second one: UI5 skips
// the Component-preload request entirely when the component module is already
// registered ("only load the Component-preload file if the Component module is
// not yet available", sap/ui/core/Component.js), and the bundle registers it.
//
// Apart from the bootstrap line the step is ADDITIVE: every single file stays
// in the BSP unchanged, UI5 just no longer has to request them one by one.
//
// The bundle is minified, and getting it past the BSP page format is the
// interesting part: a page line cannot be longer than 255 characters, and
// run.js chops anything longer into 255-character chunks that the SAP side
// serves back with newlines in between - which splits JavaScript tokens and
// string literals. Minified output is one line per module, up to 18k
// characters. So the bundle goes through three stages:
//
//   1. terser reprints it with format.max_line_len, which breaks between
//      statements - it never breaks a token, but it also never breaks INSIDE
//      an expression, so ~14 lines stay far over the limit (long dependency
//      arrays, CSS template literals, a 4k help-text array).
//   2. wrapLongLines breaks those, and only at places JavaScript allows: after
//      a comma or semicolon outside any literal, or - for a literal too long to
//      have either - by rewriting it as a parenthesised concatenation and
//      breaking after the operators.
//   3. assertSameProgram re-minifies the wrapped bundle and the bundle stage 1
//      started from, and fails the build unless both collapse to the exact same
//      code. A break in the wrong place - inside a regex literal, or one that
//      lets automatic semicolon insertion change the parse - cannot survive
//      that comparison, so a wrong guess fails the build instead of shipping.
//
// Debugging is unaffected: every module is still in the BSP as its own
// unminified page, and `sap-ui-debug=true` makes UI5 load those instead of the
// bundle.

const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const terser = require('terser');

// Same working-directory contract as run.js
const appDir = './frontend/app';
const webappDir = path.join(appDir, 'webapp');
const distDir = path.join(appDir, 'dist');
const builtBundleName = 'Component-preload.js';

// The delivered name - no hyphen, so it survives CREATE_NEW_PAGE.
const bundleName = 'preload.js';
const bundleModule = 'z2ui5/preload';

// The bootstrap module index.html starts the app with today, and what it is
// replaced by: loading the bundle as the oninit module registers every module
// first, and pulling in ComponentSupport as its dependency then starts the
// component (ComponentSupport.run() runs when the module is required). Written
// as a module reference, not a global function name, because the legacy-free
// (UI5 2.x) bootstrap of standard_v2 only accepts `module:`.
const bootModule = 'module:sap/ui/core/ComponentSupport';
const bootReplacement = `module:${bundleModule}`;
const bootTail = `sap.ui.define(["sap/ui/core/ComponentSupport"], function () {\n  "use strict";\n});\n`;

// A BSP page line, as in run.js - the limit this build has to respect.
const bspLineWidth = 255;

// What terser is asked to keep lines under in stage 1. Anything under the page
// limit works; the margin is there so stage 2 has to touch as little as
// possible, and it costs ~200 bytes gzipped over printing at the limit.
const printWidth = 200;

// How long a piece of a split literal may get. Small enough that a piece plus
// its quotes, its `+` and whatever code shares the line still fits the page.
const literalChunk = 180;

// bsp_rename --with-namespace rewrites the UI5 namespace inside quoted module
// ids, so a line full of them GROWS - and rename-bsp re-pads the page
// afterwards, chopping anything that no longer fits. Unminified lines had
// room to spare; minified ones sit right at the limit, so the room is reserved
// here instead. A renamed namespace is capped at 15 characters (the BSP name
// limit), which is 10 more than "z2ui5".
const namespaceRefs = /(["'])z2ui5(?:[/.]|\1)/g;
const renameHeadroom = 10;

// What a line will cost once a rename has had its way with it.
function pageCost(text) {
    return text.length + (text.match(namespaceRefs) || []).length * renameHeadroom;
}

// UI5 Tooling builds a project, not a folder: it wants a ui5.yaml next to
// webapp/ and a package.json it can resolve the project from. Neither belongs
// to the delivered webapp, so both are written here and removed again in the
// cleanup below. The version is never rendered into the output (the sources
// carry no ${version} placeholder), so it cannot make the build irreproducible.
const tempProjectFiles = {
    'ui5.yaml': fs.readFileSync(path.join(__dirname, 'ui5-build.yaml'), 'utf8'),
    'package.json': '{\n  "name": "z2ui5",\n  "version": "0.0.1",\n  "private": true\n}\n',
};

function resolveUi5Cli() {
    try {
        return require.resolve('@ui5/cli/bin/ui5.cjs');
    } catch {
        throw new Error(
            '@ui5/cli not found - run `npm ci` in the repository root before building a BSP branch.',
        );
    }
}

// A backslash line continuation is NOT an option here, even though it is what
// one would reach for inside a long literal: run.js pads every page line to 255
// characters, so the backslash ends up followed by spaces and stops continuing
// anything. Everything below therefore breaks only between tokens, where the
// trailing padding is plain whitespace.

// Splits one line of minified JavaScript into atoms - pieces that must stay
// together, each flagged with whether a newline may follow it. Two sources of
// break points, and no others:
//   * after a comma or semicolon in code. A statement is incomplete after
//     either, so automatic semicolon insertion cannot reinterpret the break.
//   * inside a long string or template literal, which is rewritten as a
//     parenthesised concatenation - ("aaa" + "bbb") - with the breaks after
//     the operators. The parentheses keep it independent of the precedence of
//     whatever surrounds the literal.
// Regex literals, tagged templates and comments are recognised only to be kept
// intact - a comma inside /a{1,2}/ is not a break point, and splitting a tagged
// template would change what the tag receives. Whether a `/` opens a regex or
// divides is the one judgement call in here; assertSameProgram is what turns a
// wrong one into a failed build rather than a broken frontend.
function atomize(line, chunk) {
    const atoms = [];
    const push = (text, breakAfter) => { if (text !== '') atoms.push({ text, breakAfter }); };
    // Characters after which a `/` starts a regex rather than dividing.
    const beforeRegex = /[=(,:;[!&|?{}+\-*%~^<>]/;
    const beforeRegexWord = /(?:^|[^$\w])(return|typeof|instanceof|in|of|new|delete|void|case|do|else|yield|await)$/;
    // A backtick right after a value is a TAG, not a fresh literal.
    const afterValue = /[$\w)\]]$/;
    let code = '';         // code collected since the last emitted atom
    let significant = '';  // code seen so far, for the regex/division decision

    // Reads the literal opening at `start` and returns its end offset plus the
    // offsets a split may happen at (never inside an escape, never between the
    // `$` and `{` of a substitution, never inside one).
    const readLiteral = (start) => {
        const quote = line[start];
        const splits = [];
        let depth = 0;   // brace depth inside `${ ... }`
        let inSub = false;
        for (let i = start + 1; i < line.length; i++) {
            const ch = line[i];
            if (ch === '\\') { i++; continue; }
            if (inSub) {
                if (ch === '{') depth++;
                else if (ch === '}') { if (depth === 0) inSub = false; else depth--; }
                continue;
            }
            if (ch === quote) return { end: i, splits };
            if (quote === '`' && ch === '$' && line[i + 1] === '{') { inSub = true; i++; continue; }
            splits.push(i);
        }
        return { end: -1, splits };
    };

    for (let i = 0; i < line.length; i++) {
        const ch = line[i];

        if (ch === '"' || ch === "'" || ch === '`') {
            const tagged = ch === '`' && afterValue.test(significant);
            const { end, splits } = readLiteral(i);
            if (end === -1) { code += line.slice(i); break; }        // unterminated: leave it alone
            const literal = line.slice(i, end + 1);
            if (tagged || literal.length <= chunk || splits.length === 0) {
                code += literal;
            } else {
                // ("part" + "part" + ...) - greedily as long as the pieces get.
                push(code + '(', false);
                code = '';
                let from = i + 1;
                let cut = splits.filter((s) => s - from <= chunk).pop();
                while (cut !== undefined && cut > from && end - from > chunk) {
                    push(`${ch}${line.slice(from, cut)}${ch}+`, true);
                    from = cut;
                    cut = splits.filter((s) => s - from <= chunk).pop();
                }
                code = `${ch}${line.slice(from, end)}${ch})`;
            }
            significant = ch;
            i = end;
            continue;
        }

        if (ch === '/' && line[i + 1] === '/') { code += line.slice(i); break; }   // line comment
        if (ch === '/' && line[i + 1] === '*') {
            const end = line.indexOf('*/', i + 2);
            if (end === -1) { code += line.slice(i); break; }
            code += line.slice(i, end + 2);
            i = end + 1;
            continue;
        }
        if (ch === '/') {
            const prev = significant.trimEnd();
            if (prev === '' || beforeRegex.test(prev.slice(-1)) || beforeRegexWord.test(prev)) {
                let end = i + 1;
                let inClass = false;
                for (; end < line.length; end++) {
                    if (line[end] === '\\') { end++; continue; }
                    if (line[end] === '[') inClass = true;
                    else if (line[end] === ']') inClass = false;
                    else if (line[end] === '/' && !inClass) break;
                }
                while (end + 1 < line.length && /[a-z]/.test(line[end + 1])) end++;   // flags
                code += line.slice(i, end + 1);
                significant = '/';
                i = end;
                continue;
            }
        }

        code += ch;
        significant += ch;
        if (ch === ',' || ch === ';') { push(code, true); code = ''; }
    }
    push(code, false);
    return atoms;
}

// Breaks `line` into pieces of at most `limit` characters, greedily filling
// each one. Returns null when a piece cannot be made to fit - the caller turns
// that into a build failure naming the line, which is far better than emitting
// something run.js would silently chop.
function wrapLine(line, limit, chunk) {
    if (pageCost(line) <= limit) return [line];
    const out = [];
    let current = '';   // the piece being filled, always ending at a break point
    let pending = '';   // atoms since the last break point - they cannot be split
    const place = () => {
        if (current !== '' && pageCost(current + pending) > limit) {
            out.push(current);
            current = '';
        }
        current += pending;
        pending = '';
    };
    for (const atom of atomize(line, chunk)) {
        pending += atom.text;
        if (atom.breakAfter) place();
    }
    place();
    if (current !== '') out.push(current);
    return out.every((piece) => pageCost(piece) <= limit) ? out : null;
}

function wrapLongLines(code, limit, chunk) {
    return code.split('\n').map((line, index) => {
        const pieces = wrapLine(line, limit, chunk);
        if (!pieces) {
            throw new Error(
                `${bundleName} line ${index + 1} is ${line.length} characters and offers no place to ` +
                `break it under ${limit} - a BSP page cannot carry it. The construct behind it is one ` +
                'the breaker keeps intact: a regex literal, a tagged template, or a literal with no ' +
                'splittable position. Shorten it in the frontend source, or exclude the module from ' +
                'the bundle in ui5-build.yaml.',
            );
        }
        return pieces.join('\n');
    }).join('\n');
}

// Both sides are re-minified with the same settings, so anything that is only
// formatting disappears and only a changed program survives as a difference.
// `evaluate` is what folds the concatenations the breaker introduced - and
// every other constant expression, on both sides alike - back into the single
// literal they came from, so the two sides are comparable at all.
function assertSameProgram(before, after) {
    const collapse = (code, label) => {
        const result = terser.minify_sync(code, {
            compress: { defaults: false, evaluate: true },
            mangle: false,
            format: { ascii_only: true },
        });
        if (result.error) throw new Error(`${bundleName}: ${label} does not parse - ${result.error}`);
        return result.code;
    };
    if (collapse(before, 'the built bundle') !== collapse(after, 'the wrapped bundle')) {
        throw new Error(
            `${bundleName}: wrapping the bundle for the BSP page format changed the program. ` +
            'A line break landed somewhere it changes the parse - see breakPoints() in preload.js.',
        );
    }
}

// Minify, then reprint at a line width the BSP can carry.
function minifyForBsp(code) {
    const result = terser.minify_sync(code, {
        compress: false,   // the ui5 build already compressed and mangled
        mangle: false,
        format: { max_line_len: printWidth, ascii_only: true, comments: false },
    });
    if (result.error) throw new Error(`${bundleName}: reprinting the bundle failed - ${result.error}`);
    const wrapped = wrapLongLines(result.code, bspLineWidth, literalChunk);
    assertSameProgram(code, wrapped);
    return wrapped;
}

function runUi5Build() {
    try {
        execFileSync(
            process.execPath,
            [resolveUi5Cli(), 'build', '--config', 'ui5.yaml', '--clean-dest', '--dest', 'dist'],
            { cwd: appDir, stdio: ['ignore', 'pipe', 'pipe'] },
        );
    } catch (error) {
        // The build log is the only thing that says WHY it failed, and it is
        // captured above so the branch build stays quiet on the happy path.
        process.stderr.write(String(error.stdout ?? ''));
        process.stderr.write(String(error.stderr ?? ''));
        throw error;
    }
}

// The bundler appends a sourceMappingURL for Component-preload.js.map. The map
// is not worth a BSP page - every module is served next to the bundle as its
// own unminified page, which is what sap-ui-debug=true loads anyway - and a
// reference to a file that is not there is exactly the 404 this step removes.
// (terser drops the comment as well; this keeps the input clean either way.)
function stripSourceMappingUrl(content) {
    return content.replace(/^\/\/# sourceMappingURL=.*\r?\n?/m, '');
}

// index.html boots the app through the bundle instead of ComponentSupport
// directly. Fails loudly rather than shipping a bundle nothing ever loads.
function patchIndexHtml() {
    const file = path.join(webappDir, 'index.html');
    const html = fs.readFileSync(file, 'utf8');
    if (!html.includes(bootModule)) {
        throw new Error(
            `index.html: bootstrap module "${bootModule}" not found - the bootstrap changed, ` +
            `so ${bundleName} would be built and never loaded. Adjust bootModule in preload.js.`,
        );
    }
    fs.writeFileSync(file, html.split(bootModule).join(bootReplacement), 'utf8');
}

function assertBspCompatible(content) {
    if (!/sap\.ui\.predefine\(\s*"z2ui5\/Component"/.test(content)) {
        throw new Error(
            `${bundleName}: no "z2ui5/Component" module in the bundle - the build produced ` +
            'something other than the component preload.',
        );
    }
    // A BSP page name is restricted; the hyphen in the built name is exactly
    // what CREATE_NEW_PAGE rejects, so guard against shipping one by accident.
    if (/[^A-Za-z0-9_.]/.test(bundleName)) {
        throw new Error(
            `${bundleName}: a BSP page name may only contain letters, digits, "_" and "." - ` +
            'CL_O2_API_PAGES=>CREATE_NEW_PAGE fails the whole import with sy-subrc=2 (invalid_name).',
        );
    }
    content.split('\n').forEach((line, index) => {
        if (line.length > bspLineWidth) {
            throw new Error(
                `${bundleName} line ${index + 1} is ${line.length} characters (max ${bspLineWidth}) - ` +
                'a BSP page cannot carry it and run.js would chop it into 255-character chunks, ' +
                'breaking the JavaScript. Shorten the frontend source line, or exclude the ' +
                'resource from the bundle in ui5-build.yaml.',
            );
        }
    });
}

for (const [name, content] of Object.entries(tempProjectFiles)) {
    fs.writeFileSync(path.join(appDir, name), content, 'utf8');
}

try {
    runUi5Build();

    const built = stripSourceMappingUrl(fs.readFileSync(path.join(distDir, builtBundleName), 'utf8'));
    const bundle = minifyForBsp(built) + bootTail;
    assertBspCompatible(bundle);
    fs.writeFileSync(path.join(webappDir, bundleName), bundle, 'utf8');
    patchIndexHtml();

    const modules = (bundle.match(/sap\.ui\.predefine\(/g) || []).length;
    const longest = Math.max(...bundle.split('\n').map((l) => l.length));
    console.log(
        `Generated ${bundleName} (${modules} modules, ${bundle.length} bytes, longest line ${longest}), ` +
        'index.html boots it.',
    );
} finally {
    fs.rmSync(distDir, { recursive: true, force: true });
    for (const name of Object.keys(tempProjectFiles)) {
        fs.rmSync(path.join(appDir, name), { force: true });
    }
}
