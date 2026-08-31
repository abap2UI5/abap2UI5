const fs = require('fs');
const path = require('path');
const acorn = require('acorn');
const terser = require('terser');
const abapClassTemplate = require('./abapClassTemplate');
const xmlTemplate = require('./abapXMLTemplate');

// Define source and target directories
const sourceDir = path.join(__dirname, '../../app/webapp');
const targetDir = path.join(__dirname, '../../src/01/03');

// Initial XML content with BOM
const initialXMLContent = `\uFEFF<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DEVC>
    <CTEXT>abap2UI5 - ui5 frontend (generated)</CTEXT>
   </DEVC>
  </asx:values>
 </asx:abap>
</abapGit>
`;

// Function to read the file content from the source directory
function readFile(filePath) {
    return fs.promises.readFile(filePath, 'utf-8');
}

// Function to create a new file in the target directory
function createFileInTargetDir(targetFilePath, content) {
    return fs.promises.writeFile(targetFilePath, content, 'utf-8');
}

// Guard 1: the frontend source is embedded into an ABAP string constant,
// which abaplint checks with the 7bit_ascii rule. A non-ASCII byte (smart
// quote, ellipsis, arrow, ...) breaks generation/lint downstream with a
// confusing error, so fail here at the exact source line instead. Runtime
// non-ASCII must be built via String.fromCharCode / entity decoding (see
// AGENTS.md rule 14). For .js files this also runs BEFORE the comment strip
// below reflows the code, so the reported line number is one the author can
// find in app/webapp.
function assertSevenBitAscii(content, className) {
    content.split('\n').forEach((line, index) => {
        // The range IS ASCII, control characters included: this line is the
        // 7bit_ascii rule itself.
        // eslint-disable-next-line no-control-regex
        const nonAscii = line.match(/[^\x00-\x7F]/);
        if (nonAscii) {
            throw new Error(
                `${className} line ${index + 1}: non-ASCII character ${JSON.stringify(nonAscii[0])} ` +
                `(code ${nonAscii[0].codePointAt(0)}) - frontend source must be 7-bit ASCII: ${line.trim()}`,
            );
        }
    });
}

// Both sides are re-minified with the same settings, so anything that is only
// formatting disappears and only a changed program survives as a difference
// (ported from tools/app2bsp/preload.js). `evaluate` folds constant
// expressions identically on both sides, so the two prints are comparable.
function assertSameProgram(before, after, relPath) {
    const collapse = (code, label) => {
        const result = terser.minify_sync(code, {
            compress: { defaults: false, evaluate: true },
            mangle: false,
            format: { ascii_only: true },
        });
        if (result.error) {
            throw new Error(`${relPath}: ${label} does not parse - ${result.error}`);
        }
        return result.code;
    };
    if (collapse(before, 'the source') !== collapse(after, 'the comment-stripped source')) {
        throw new Error(
            `${relPath}: stripping the comments changed the program - ` +
            'a construct terser reprints differently; report it and embed this file unstripped.',
        );
    }
}

// The app's own Prettier (also what `npm run app2abap` formats app/webapp
// with) - required from app/node_modules because the root has no prettier
// of its own. Lazy so the error names the fix instead of failing the
// require at import time when app deps are missing.
let prettierModule = null;
function appPrettier() {
    if (!prettierModule) {
        try {
            prettierModule = require(path.join(__dirname, '../../app/node_modules/prettier'));
        } catch {
            throw new Error(
                "comment strip needs the app toolchain - run 'npm --prefix app ci' first " +
                '(npm run app2abap and check:app2abap install it for you)',
            );
        }
    }
    return prettierModule;
}

// The embedded copy of a .js file is a DELIVERY artefact - the readable
// source lives in app/webapp, and nobody patches src/01/03 (AGENTS.md
// rule 2). The comments are therefore pure payload on every ICF cold start,
// and this codebase comments heavily; stripping them keeps the GET response
// (and the src/01/03 diff noise per frontend change) roughly half the size.
// Everything else stays: no compress, no mangle, no reprint - a browser
// stack trace still shows the real identifiers and (near-)real lines.
//
// The comments are cut OUT OF THE ORIGINAL TEXT by position (acorn's
// tokenizer reports where each one starts and ends), never by reprinting
// the AST: a terser reprint escapes the real newlines inside multi-line
// template literals into one giant line, which cannot be broken again and
// blows the 255-char ABAP line cap (guard 2). Prettier then only tidies
// the holes the cuts left (dangling indentation, runs of blank lines) with
// the app's own config, and terser re-parses both sides once to prove the
// PROGRAM did not change.
async function stripJsComments(source, file, relPath) {
    const comments = [];
    try {
        acorn.parse(source, {
            ecmaVersion: 'latest',
            onComment: (_isBlock, _text, start, end) => comments.push([start, end]),
        });
    } catch (e) {
        throw new Error(`${relPath}: does not parse - ${e.message}`, { cause: e });
    }
    let code = source;
    for (const [start, end] of comments.reverse()) {
        code = code.slice(0, start) + code.slice(end);
    }
    const prettier = appPrettier();
    const config = (await prettier.resolveConfig(file)) || {};
    code = await prettier.format(code, { ...config, parser: 'babel' });
    assertSameProgram(source, code, relPath);
    return code;
}

// Function to format the content into an ABAP class method
function formatAsAbapClass(content, className, isSpecialFile, sourcePath) {
    assertSevenBitAscii(content, className);
    const lines = content.split('\n');
    const formattedLines = lines.map((line, index) => {
        line = line.replace(/\s+$/, ''); // Remove trailing spaces

        let formattedLine = `             \`${line.replace(/`/g, '``')}\` && ${isSpecialFile ? '' : '|\\n|  &&'}`;
        formattedLine = formattedLine.replace(/&&\s+$/, '&&'); // Remove trailing spaces after &&

        // Guard 2: an ABAP source line is capped at 255 characters. A generated
        // line over the limit breaks the ABAP compile/lint downstream with an
        // opaque error; surface it here against the source line so it is obvious
        // which frontend line to shorten.
        if (formattedLine.length > 255) {
            throw new Error(
                `${className} line ${index + 1}: generated ABAP line is ${formattedLine.length} chars ` +
                `(max 255) - shorten this frontend source line: ${line.trim()}`,
            );
        }
        if ((index + 1) % 400 === 0) {
            // ABAP caps the length of a chained expression, so the result is
            // split into several statements every 400 lines. This line
            // already carries its own separator (|\n| for normal files, none
            // for special files), so close the statement by turning its
            // trailing `&&` into `.` rather than appending a second |\n| -
            // the latter inserted a spurious blank line every 400 lines and
            // would have corrupted newline-free special files past that size.
            return `${formattedLine.replace(/\s*&&$/, '.')}\n    result = result &&`;
        }
        return formattedLine;
    });
    return abapClassTemplate(className, formattedLines.join('\n'), sourcePath);
}

// Embedded frontend artefacts carry the `ui5f` segment (UI5 frontend); plain
// ABAP artefacts use `ui5` (z2ui5_cl_ui5_view_builder).
const CLASS_NAME_PREFIX = 'z2ui5_cl_ui5f_';

// ABAP object names are capped at 30 characters, but a generated name must
// survive the rename workflow (.github/workflows/build_rename.yaml), which
// swaps the 5-character `z2ui5` for a namespace of up to 10 characters. So the
// budget here is 25, not 30 - that is what keeps
// .github/abaplint/rename.jsonc down to a single catch-all pattern with no
// per-class truncation entries.
const MAX_CLASS_NAME_LENGTH = 25;

// Short stems for the frontend files whose basename does not fit into
// MAX_CLASS_NAME_LENGTH, keyed by path relative to app/webapp. Curated instead
// of truncated: mechanical shortening is what produced stems like
// `developertool_xml` (a DeveloperTools fragment that lost its plural) and
// `smartmultiinpu_js`. Names not listed here keep their basename.
const CLASS_NAME_STEMS = {
    'Component.js': 'comp_js',
    'cc/CameraPicture.js': 'campic_js',
    'cc/CameraSelector.js': 'camsel_js',
    'cc/FileUploader.js': 'uploader_js',
    'cc/Geolocation.js': 'geoloc_js',
    'cc/MessageManager.js': 'msgmgr_js',
    'cc/MultiInputExt.js': 'multiinp_js',
    'cc/Scrolling.js': 'scroll_js',
    'cc/SmartMultiInputExt.js': 'smartinp_js',
    'cc/UITableExt.js': 'uitable_js',
    'cc/UploadSetExt.js': 'upldset_js',
    'cc/Websocket.js': 'websock_js',
    'devtools/AbapSource.js': 'abapsrc_js',
    'devtools/DeveloperTools.fragment.xml': 'dtools_xml',
    'devtools/DeveloperTools.js': 'dtools_js',
    // `format_js` is taken by model/formatter.js, and a collision is a hard
    // error rather than a silent overwrite - so this one carries the folder.
    'devtools/Format.js': 'dtformat_js',
    'core/ErrorView.js': 'errview_js',
    'core/FrontendAction.js': 'frontact_js',
    'core/ScrollFocus.js': 'scrfocus_js',
    'core/ViewSlots.js': 'viewslot_js',
    'core/actions/ControlCall.js': 'ctrlcall_js',
    'core/actions/Launchpad.js': 'launchpd_js',
    'core/actions/LegacyCustomJs.js': 'legacy_js',
    'core/actions/Shortcuts.js': 'shortcut_js',
    'manifest.json': 'manifest',
    'model/formatter.js': 'format_js',
};

// Function to generate a class name from a file path
function generateClassName(filePath) {
    const relativePath = path.relative(sourceDir, filePath);
    const relPath = relativePath.split(path.sep).join('/');
    const parts = relativePath.split(path.sep);
    const fileName = parts.pop().split('.');
    if (fileName.length > 2) {
        fileName.splice(1, 1); // Remove the middle part
    }
    const stem = CLASS_NAME_STEMS[relPath] || fileName.join('_').toLowerCase();
    const className = `${CLASS_NAME_PREFIX}${stem}`;
    // Guard 3: fail instead of truncating. A silently shortened name stays
    // valid ABAP and only surfaces much later, as an opaque "Name not allowed"
    // out of the rename run - the exact failure mode this cap removes.
    if (className.length > MAX_CLASS_NAME_LENGTH) {
        throw new Error(
            `${relPath}: generated class name '${className}' is ${className.length} chars ` +
            `(max ${MAX_CLASS_NAME_LENGTH}) - add a short stem for this file to ` +
            `CLASS_NAME_STEMS in tools/app2abap/trans2abap.js`,
        );
    }
    return className;
}

// Builds the generated z2ui5_cl_ui5f_preload class. It returns the
// sap.ui.require.preload entries for every embedded frontend file, so the
// preload list used by z2ui5_cl_http_handler can never run out of sync with
// the files in app/webapp. style.css and Component.js take their content /
// custom-js suffix from the exit configuration, hence the two parameters.
function buildPreloadClass(entries) {
    const entryLines = entries.map(({ urlPath, className, isJs, isComponent, isStyleCss }) => {
        // A .js entry is a function body - the source is JavaScript and goes in
        // verbatim. Every other entry is a text resource embedded as a
        // single-quoted JS string literal, so its content must be escaped for
        // that literal (see escape_js_literal below).
        if (isStyleCss) {
            return `|      "${urlPath}": '{ escape_js_literal( styles_css ) }',| && |\\n|`;
        }
        if (isJs) {
            const suffix = isComponent ? `{ custom_js }` : '';
            return `|      "${urlPath}": function()\\{{ ${className}=>get( ) }${suffix}\\},| && |\\n|`;
        }
        return `|      "${urlPath}": '{ escape_js_literal( ${className}=>get( ) ) }',| && |\\n|`;
    });
    const joined = entryLines.join(' &&\n             ');
    return `* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* tools/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_preload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      IMPORTING
        styles_css    TYPE string
        custom_js     TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS escape_js_literal
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5f_preload IMPLEMENTATION.

  METHOD get.

    result = ${joined}.

  ENDMETHOD.

  METHOD escape_js_literal.

    " Every non-.js resource in get( ) is embedded as a JavaScript
    " single-quoted string literal, inside the single <script> block that
    " defines onInitComponent (z2ui5_cl_http_handler=>_http_get). Its content
    " is arbitrary text and does carry apostrophes - a UI5 expression binding
    " in a fragment (title="{= \${/appName} ? 'a' : 'b' }") writes them, and so
    " does a customer's own styles_css from the exit. An unescaped one ends the
    " literal early, which is a syntax error for the whole block: the browser
    " then never defines onInitComponent, the bootstrap call fails and the page
    " stays blank. Escape for the literal here instead of banning the
    " characters in the frontend sources.
    " Backslash goes first so it cannot escape the backslashes added below it.
    result = replace( val  = val
                      sub  = \`\\\`
                      with = \`\\\\\`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = \`'\`
                      with = \`\\'\`
                      occ  = 0 ).
    " a raw line break ends a JS string literal just like an apostrophe does -
    " only styles_css can carry one, the generated resources are single-line.
    " char constants come from the context class - the one place allowed to
    " reference cl_abap_char_utilities (see "Utilities" in AGENTS.md)
    result = replace( val  = result
                      sub  = z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf(1)
                      with = \`\\r\`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = z2ui5_cl_ui5_util_context=>cv_char_util_newline
                      with = \`\\n\`
                      occ  = 0 ).

  ENDMETHOD.

ENDCLASS.
`;
}

// Function to recursively get all files in a directory
function getAllFiles(dirPath, arrayOfFiles) {
    const files = fs.readdirSync(dirPath);

    arrayOfFiles = arrayOfFiles || [];

    files.forEach(file => {
        const filePath = path.join(dirPath, file);
        if (fs.statSync(filePath).isDirectory()) {
            arrayOfFiles = getAllFiles(filePath, arrayOfFiles);
        } else {
            arrayOfFiles.push(filePath);
        }
    });

    return arrayOfFiles;
}

// Main function to read the source files and create new target files
async function main() {
    try {
        // Everything is generated into memory FIRST and written only once the
        // whole set is built. The target directory used to be deleted as the
        // very first statement, before a single guard had run - so a source
        // file with a non-ASCII character, a class-name collision or an
        // over-long line left src/01/03 wiped and half-regenerated in the
        // contributor's working tree, and `git checkout src/01/03` was the
        // only way back. The drift gate then reported the wreckage instead of
        // the cause. Nothing below touches the filesystem until `outputs` is
        // complete.
        const outputs = [];
        const emit = (filePath, content) => outputs.push({ filePath, content });

        // The initial XML file with BOM
        emit(path.join(targetDir, 'package.devc.xml'), initialXMLContent);

        // Sort so the generation order (and console log) is deterministic
        // regardless of the filesystem's readdir order.
        const files = getAllFiles(sourceDir).sort();
        const preloadEntries = [];

        // Class names ignore folders (cc/Foo.js and Foo.js would both map to
        // z2ui5_cl_ui5f_foo_js), so duplicate basenames silently overwrite
        // each other. Fail fast instead.
        const seenClassNames = new Map();
        const classNameByFile = new Map();
        for (const file of files) {
            const cn = generateClassName(file);
            if (seenClassNames.has(cn)) {
                throw new Error(
                    `class name collision: ${file} and ${seenClassNames.get(cn)} both map to ${cn}`,
                );
            }
            seenClassNames.set(cn, file);
            classNameByFile.set(file, cn);
        }

        for (const file of files) {
            let sourceContent = await readFile(file);
            console.log(`Source file content fetched successfully for ${file}.`);

            const className = classNameByFile.get(file);
            const relPath = path.relative(sourceDir, file).split(path.sep).join('/');
            const isSpecialFile = file.endsWith('.xml') || file.endsWith('.json') || file.endsWith('.html') || file.endsWith('.css');
            // Only .js is stripped: the special files (.xml/.json/.html/.css)
            // go in untouched - their comments are structure (fragment
            // documentation, manifest annotations) and none of them is
            // JavaScript for terser to reprint.
            if (file.endsWith('.js')) {
                // ASCII first, against the author's own line numbers
                assertSevenBitAscii(sourceContent, className);
                sourceContent = await stripJsComments(sourceContent, file, relPath);
            }
            const abapClassContent = formatAsAbapClass(sourceContent, className, isSpecialFile, relPath);

            const targetFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.abap`);
            emit(targetFilePath, abapClassContent);

            const xmlContent = xmlTemplate(className, `abap2UI5 - ${path.basename(file)}`);
            const xmlFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.xml`);
            emit(xmlFilePath, `\uFEFF${xmlContent}`);

            // Collect the preload entry. index.html is the standalone dev
            // page and is not preloaded by the generated GET response.
            if (relPath !== 'index.html') {
                preloadEntries.push({
                    urlPath: `z2ui5/${relPath}`,
                    className: className.toLowerCase(),
                    isJs: file.endsWith('.js'),
                    isComponent: relPath === 'Component.js',
                    isStyleCss: relPath === 'css/style.css',
                });
            }
        }

        // Generate the preload mapping class (sorted for a stable output).
        // Plain code-unit comparison, not localeCompare: the collation of
        // localeCompare depends on the host locale/ICU build, and the sort
        // order is committed output (src/01/03).
        preloadEntries.sort((a, b) => (a.urlPath < b.urlPath ? -1 : a.urlPath > b.urlPath ? 1 : 0));
        emit(path.join(targetDir, 'z2ui5_cl_ui5f_preload.clas.abap'), buildPreloadClass(preloadEntries));
        emit(
            path.join(targetDir, 'z2ui5_cl_ui5f_preload.clas.xml'),
            `\uFEFF${xmlTemplate('z2ui5_cl_ui5f_preload', 'abap2UI5 - preload mapping')}`,
        );

        // Every guard has passed and every byte is in hand - only now is the
        // committed tree replaced.
        fs.rmSync(targetDir, { recursive: true, force: true });
        fs.mkdirSync(targetDir, { recursive: true });
        for (const { filePath, content } of outputs) {
            await createFileInTargetDir(filePath, content);
            console.log(`Target file created successfully at: ${filePath}`);
        }
        console.log(`${outputs.length} file(s) written to ${targetDir}`);
    } catch (error) {
        // Signal failure so CI (check_app2abap.yaml, autofix.yaml) does not
        // treat a broken generation run as success and commit a partial
        // src/01/03. Since the write phase above is the last thing main( )
        // does, a failure reported here also means the committed tree was
        // never touched.
        console.error('Error:', error.message);
        process.exitCode = 1;
    }
}

// Run the main function
main();
