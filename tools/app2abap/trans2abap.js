const fs = require("fs");
const path = require("path");
const os = require("os");
const crypto = require("crypto");
const terser = require("terser");
const xmlTemplate = require("./abapXMLTemplate");

// Define source and target directories
const sourceDir = path.join(__dirname, "../../bundle/webapp");
const targetDir = path.join(__dirname, "../../src/01/03");

// What the GET page itself carries, and nothing of it is the frontend: the
// page is the minimal UI5 app of app_source/webapp - a component with one XML
// view with one z2ui5.embed.Container in it - and the control itself, from
// abap2UI5-addons/embed-ui5-control at the commit node/setup/fetch-deps.mjs pins
// (checked out into tools/deps/, see CONTROL). The control loads the
// frontend through ?z2ui5-bundle. The page is a variant of that app, not a
// second one: its inline script holds the app's files as a preload, because
// a node serves no files. index.html stays out - the handler writes the
// page.
const repoDir = path.join(__dirname, "../..");
// The end of the frontend bundle, a file of its own: the module z2ui5/embed,
// defined the moment the script has run (its header says why it is no module
// of bundle/webapp). It carries one token, which
// z2ui5_cl_ui5_http_handler=>_http_get_bundle replaces per request.
const BUNDLE_TAIL = "bundle/tail/embed.js";
const NODE_PATH_TOKEN = "@z2ui5-node-path@";
const pageDir = "app_source/webapp";
// The control: its source is abap2UI5-addons/embed-ui5-control, pinned. Where the app
// registers it (sap.ui5/resourceRoots of its manifest) - the BSP carries it
// there, the page's preload under its module name.
const CONTROL = "tools/deps/embed-control/packages/embed-control/src/Container.js";
const CONTROL_PATH = "thirdparty/z2ui5/embed/";
const PAGE_SOURCES = [
  {
    source: `${pageDir}/Component.js`,
    urlPath: "z2ui5/Component.js",
  },
  {
    source: `${pageDir}/manifest.json`,
    urlPath: "z2ui5/manifest.json",
  },
  {
    source: `${pageDir}/view/Main.view.xml`,
    urlPath: "abap2ui5/page/view/Main.view.xml",
  },
  {
    source: CONTROL,
    urlPath: "z2ui5/embed/Container.js",
  },
];

// The same app once more, as the files a launchpad loads: the BSP Z2UI5 of
// src/03/02, written by @abap2ui5/bsp (tools/bsp) from the whole folder,
// index.html included. Until 2026-11 it was built into a branch of
// abap2UI5/frontend (standard_new) and installed from there; its names -
// the BSP, its two ICF nodes - are the ones those installations have.
const bspDir = path.join(repoDir, "src/03/02");
const BSP = {
  name: "Z2UI5",
  text: "abap2UI5 frontend (generated)",
  icfText: "abap2UI5 - Frontend",
  packageText: "abap2UI5 - launchpad app (generated)",
};

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
  return fs.promises.readFile(filePath, "utf-8");
}

// Function to create a new file in the target directory
function createFileInTargetDir(targetFilePath, content) {
  return fs.promises.writeFile(targetFilePath, content, "utf-8");
}

// Guard 1: the frontend source is embedded into an ABAP string constant,
// which abaplint checks with the 7bit_ascii rule. A non-ASCII byte (smart
// quote, ellipsis, arrow, ...) breaks generation/lint downstream with a
// confusing error, so fail here at the exact source line instead. Runtime
// non-ASCII must be built via String.fromCharCode / entity decoding (see
// AGENTS.md rule 14). For .js files this also runs BEFORE the comment strip
// below reflows the code, so the reported line number is one the author can
// find in bundle/webapp.
function assertSevenBitAscii(content, className) {
  content.split("\n").forEach((line, index) => {
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
    // A tab IS 7-bit ASCII, and lands in the backtick literal as a tab -
    // where abaplint's contains_tab refuses the generated class, naming
    // the class and not the bundle/webapp file. Prettier only formats the
    // .js files, so a tab in an XML or CSS source has nothing else to
    // stop it before this point.
    if (line.includes("\t")) {
      throw new Error(
        `${className} line ${index + 1}: tab character - frontend source is indented with spaces: ${line.trim()}`,
      );
    }
  });
}

// The special files (.xml/.html/.json/.css) are embedded with the trailing
// whitespace of every line stripped and the lines joined WITHOUT a newline
// (formatAsAbapClass / embeddedValue). For an XML view that is harmless
// where the line break sits between tags, inside a tag or inside a comment,
// and nothing but the browser's own XML parser would tell when it is not:
// a text node written across lines, or an attribute value that spans a
// line break, loses the break and the spaces in the shipped page while the
// cloud/BSP delivery ships the file verbatim - a divergence between the two
// delivery paths no gate sees. The .js twin of this proof is
// assertSameProgram; here the content is not a program, so the guard
// refuses the two shapes that lose something instead: a line that ends
// inside a quoted attribute value, and a line that ends in text content
// (its last non-blank character is not a `>`), both outside comments.
// JSON and CSS carry no multi-line strings, and index.html is the
// standalone dev page whose <style>/<script> bodies are raw text this XML
// scanner cannot read (and which the GET shell never ships), so only the
// XML views and fragments are scanned.
function assertNoLossInSpecialFile(content, className, relPath) {
  if (!relPath.endsWith(".xml")) return;
  // the scanner's state at the start of each line
  let state = "text"; // text | tag | attr | comment
  let quote = "";
  content.split("\n").forEach((line, index) => {
    const stripped = line.replace(/\s+$/, "");
    let i = 0;
    while (i < line.length) {
      const rest = line.slice(i);
      if (state === "comment") {
        const end = rest.indexOf("-->");
        if (end < 0) break;
        i += end + 3;
        state = "text";
      } else if (state === "text") {
        if (rest.startsWith("<!--")) {
          state = "comment";
          i += 4;
        } else if (rest.startsWith("<")) {
          state = "tag";
          i += 1;
        } else {
          i += 1;
        }
      } else if (state === "tag") {
        const c = rest[0];
        if (c === '"' || c === "'") {
          state = "attr";
          quote = c;
        } else if (c === ">") {
          state = "text";
        }
        i += 1;
      } else {
        // attr
        if (rest[0] === quote) state = "tag";
        i += 1;
      }
    }
    const fail = (what) => {
      throw new Error(
        `${className} line ${index + 1} (${relPath}): ${what} - the embedded copy joins the lines ` +
          `without a newline and strips trailing whitespace, so the page would not ship what the ` +
          `file says; write it on one line: ${line.trim()}`,
      );
    };
    if (state === "attr") fail(`the attribute value spans a line break`);
    if (state === "text" && stripped !== "" && !stripped.endsWith(">")) {
      fail(`text content ends at a line break`);
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
  if (
    collapse(before, "the source") !==
    collapse(after, "the embedded copy")
  ) {
    throw new Error(
      `${relPath}: embedding changed the program - the comment strip, or the ` +
        "trailing whitespace every embedded line loses (inside a template literal " +
        'it is part of the string: write it as ${" "} or \\x20 there).',
    );
  }
}

// The embedded copy of a .js file is a DELIVERY artefact - the readable
// source lives in bundle/webapp, and nobody patches src/01/03 (AGENTS.md
// rule 2). Comments and layout are therefore pure payload on every cold
// start of the page, and this codebase comments heavily.
//
// The copy is a terser PRINT of the source: comments and whitespace go, and
// nothing else - no compress, no mangle, so a browser stack trace still
// shows the real identifiers. It no longer shows the source's lines: a
// module is one line now (maintainer decision 2026-11-23; measured on that
// day's bundle: 354 KB -> 250 KB, gzipped 81.8 KB -> 70.9 KB, and about
// 1,400 literals for the kernel to join where there were 12,000). Mangling
// would take the bundle to 58 KB gzipped and the identifiers with it - one
// option below, and a decision of its own.
//
// Until then the comments were cut out of the original text by position
// (acorn) and Prettier tidied the holes, precisely to AVOID a reprint: a
// reprint puts a module on one giant line, and a line of the generated
// class could not be longer than ABAP's 255 characters. abapTextClass cuts
// every line into CHUNK-sized literals since 2026-11-13, so the length of a
// line of the text no longer matters.
//
// terser re-parses both sides once more to prove the PROGRAM did not change
// (assertSameProgram) - compared against what the ABAP class hands back,
// not against the print: the class strips the trailing whitespace of every
// line on the way in, and inside a multi-line template literal that
// whitespace is part of the string.
function minifyJs(source, relPath) {
  let result;
  try {
    result = terser.minify_sync(source, {
      // the sources are written for the browsers UI5 runs in today
      // (optional chaining, shorthand properties): printed as written,
      // not spelled out for an older engine
      ecma: 2020,
      compress: false,
      mangle: false,
      format: { ascii_only: true, comments: false },
    });
  } catch (e) {
    throw new Error(`${relPath}: does not parse - ${e.message}`, { cause: e });
  }
  const code = `${result.code}\n`;
  assertSameProgram(source, embeddedValue(code, false), relPath);
  return code;
}

// A text as an ABAP class whose get( ) hands back exactly that text. This is
// the whole shape of the generated package since 2026-11-13: the node serves
// a handful of finished texts - the frontend bundle, the devtools bundle, the
// page's script, the control's stylesheet - so each of them is ONE class,
// instead of one class per file of bundle/webapp that the backend put together
// again on every request (about 140 of them).
//
// The text is cut into backtick literals of at most CHUNK characters, one per
// ABAP line, so no line of the source can outgrow ABAP's 255: a line break of
// the text is |\n| behind the last literal of its line, a longer line simply
// continues in the next literal. A backtick literal keeps its trailing
// blanks, so a cut may fall anywhere. Every STATEMENT_OPERANDS operands the
// expression is closed and continued with `result = result && ...`, and every
// PART_LINES lines a new private method begins, so no method grows with the
// bundle: get( ) joins the parts.
//
// The statement was closed every 400 LINES until 1.151.0 - up to 441
// operands - and the 7.02 class scanner refuses a statement that size:
// abapGit reported the class as erroneous and z2ui5_cl_ui5f_bundle, _cc and
// _devtools did not compile (#3074). It is the same limit
// .github/scripts/generate-guide-class.mjs met in #2947 and closes at 80
// operands since; the guide's statements of 82 import on 7.02.
// check:abapgit (`operands`) fails any statement in src/ over
// MAX_CONCAT_OPERANDS, so the next generator that forgets it is caught.
const CHUNK = 200;
const STATEMENT_OPERANDS = 80;
const PART_LINES = 2000;

// a line of abapLiteralLines( ) is one literal, or one literal and |\n|
const lineOperands = (line) => (line.endsWith(" && |\\n|") ? 2 : 1);

function abapLiteralLines(text) {
  const lines = [];
  const segments = text.split("\n");
  segments.forEach((segment, index) => {
    const last = index === segments.length - 1;
    // the text after the last line break: nothing to write when it is empty
    if (last && segment === "") return;
    const chunks = segment.match(new RegExp(`[^]{1,${CHUNK}}`, "g")) || [""];
    chunks.forEach((chunk, c) => {
      const literal = `\`${chunk.replace(/`/g, "``")}\``;
      const breakAfter = c === chunks.length - 1 && !last;
      lines.push(breakAfter ? `${literal} && |\\n|` : literal);
    });
  });
  return lines;
}

function abapTextClass(className, text, header) {
  assertSevenBitAscii(text, className);
  const lines = abapLiteralLines(text);
  const parts = [];
  for (let i = 0; i < lines.length; i += PART_LINES) {
    parts.push(lines.slice(i, i + PART_LINES));
  }
  if (!parts.length) parts.push(["``"]);
  const partName = (i) => `part_${String(i + 1).padStart(2, "0")}`;
  const body = (partLines) => {
    const statements = [];
    let statement = [];
    let operands = 0;
    for (const line of partLines) {
      // result = result && ... is one operand of the continued statement
      const limit = statements.length ? STATEMENT_OPERANDS - 1 : STATEMENT_OPERANDS;
      if (statement.length && operands + lineOperands(line) > limit) {
        statements.push(statement);
        statement = [];
        operands = 0;
      }
      statement.push(line);
      operands += lineOperands(line);
    }
    statements.push(statement);
    return statements
      .map((lines, i) => {
        const first =
          i === 0 ? "    result = " : "    result = result &&\n             ";
        return `${first}${lines.join(" &&\n             ")}.`;
      })
      .join("\n");
  };
  return `* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
${header.map((line) => `* ${line}`.trimEnd()).join("\n")}
* Generated by tools/app2abap/trans2abap.js. Change the sources and run
* 'npm run app2abap' to regenerate; the check_app2abap CI gate fails any
* manual edit here.
* =====================================================================
CLASS ${className} DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

${parts
  .map(
    (_, i) => `    CLASS-METHODS ${partName(i)}
      RETURNING
        VALUE(result) TYPE string.
`,
  )
  .join("\n")}
ENDCLASS.


CLASS ${className} IMPLEMENTATION.

  METHOD get.

    result = ${parts.map((_, i) => `${partName(i)}( )`).join(" &&\n             ")}.

  ENDMETHOD.

${parts
  .map(
    (partLines, i) => `  METHOD ${partName(i)}.

${body(partLines)}

  ENDMETHOD.
`,
  )
  .join("\n")}
ENDCLASS.
`;
}

// A source file as it is embedded: the trailing whitespace of every line
// stripped, and a newline after every line of a .js file (including the empty
// one after its last newline) - none at all for the special files
// (.xml/.json/.css), whose lines are joined. The bundles and the page's
// script are put together from these values (preloadEntryText), here and
// nowhere else, so the CSP hash of the inline script is taken over the very
// text the class hands back.
function embeddedValue(content, isSpecialFile) {
  const lines = content.split("\n").map((line) => line.replace(/\s+$/, ""));
  return isSpecialFile
    ? lines.join("")
    : lines.map((line) => `${line}\n`).join("");
}

// JavaScript twin of escape_js_literal in the generated preload class (below):
// backslash first, then the apostrophe, CR, LF and every < - the order the
// ABAP method applies them in.
function escapeJsLiteral(value) {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/'/g, "\\'")
    .replace(/\r/g, "\\r")
    .replace(/\n/g, "\\n")
    .replace(/</g, "\\x3c");
}

// The lines around the preload entries in the GET page's one inline
// <script>: the global onInitComponent the bootstrap tag names in
// data-sap-ui-oninit, which registers the page's own modules (PAGE_SOURCES -
// the app of app_source/webapp with its control, NOT the frontend) and
// starts the component the page declares. Each line is followed by a newline, the first one is empty (the
// script text starts with the newline after <script>). Held once, as data,
// so the ABAP string template in buildPreloadClass and the hashed JavaScript
// string in inlineScript cannot drift apart.
const SCRIPT_OPEN = [
  "",
  "  function onInitComponent(){",
  "    sap.ui.require.preload({",
];
const SCRIPT_CLOSE = [
  "    });",
  '    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport){',
  "     ComponentSupport.run();",
  "    });",
  "  }",
];

// The lines around the same entries in the frontend BUNDLE - the script a
// GET of the node with ?z2ui5-bundle answers with (z2ui5_cl_ui5_http_handler
// =>_http_get_bundle), for a page that embeds the component. Only the
// registration: that page is running already, so nothing is started here.
//
// The component is registered a second time, as z2ui5.embed.frontend - its
// Component.js and manifest.json under z2ui5/embed/frontend/, the SAME
// function and text, so nothing is sent twice, and every other module stays
// where it is. The page that embeds the component may be a component named
// z2ui5 itself: the BSP Z2UI5 of src/03/02 and the app of the branch cloud
// are the component z2ui5 that a launchpad's target
// mappings name, and its own
// z2ui5/Component is defined before this script runs - the loader ignores a
// preload of a module it has already, and the frontend's would never be
// found under z2ui5. The z2ui5/embed module of the bundle names the second
// name (componentName), and @abap2ui5/embed-control creates the component
// under it. z2ui5/embed/ is the control's namespace; nothing is fetched
// from it, both entries are preloaded.
const BUNDLE_OPEN = ["(function () {", "  var entries = {"];
const BUNDLE_CLOSE = [
  "  };",
  "  sap.ui.require.preload(entries);",
  "  sap.ui.require.preload({",
  '    "z2ui5/embed/frontend/Component.js": entries["z2ui5/Component.js"],',
  '    "z2ui5/embed/frontend/manifest.json": entries["z2ui5/manifest.json"]',
  "  });",
  "})();",
];

// The DEVTOOLS bundle (?z2ui5-bundle=devtools, _http_get_devtools) has the
// plain shape around the deferred files of devtools/ (see DEVTOOLS_EAGER):
// only a preload, no second registration - the component is not in it.
const DEVTOOLS_OPEN = ["sap.ui.require.preload({"];
const DEVTOOLS_CLOSE = ["});"];

// The CUSTOM CONTROLS bundle (?z2ui5-bundle=cc, _http_get_cc, see CC_DIR)
// has the same preload, and one module behind it that is DEFINED the moment
// the script has run, like the frontend bundle's z2ui5/embed: it is how
// z2ui5/core/CustomControls tells that what it loaded was this bundle. A
// <script> element reports a load for any 200 answer - a logon page, a
// proxy's error page - and the view that waited would then ask the loader
// for a control nobody registered. No control: its name is lower-case, and
// nothing ever requires it.
const CC_MARKER = "z2ui5/cc/bundle";
const CC_OPEN = DEVTOOLS_OPEN;
const CC_CLOSE = [
  "});",
  `sap.ui.define("${CC_MARKER}", function () {`,
  '  "use strict";',
  "  return {};",
  "});",
];

// The developer tools are split in two. What has to be there from the
// first roundtrip on stays in the shell's inline script and in the embed
// bundle: devtools/DevTools.js (the facade the component installs - the
// Ctrl+F12 shortcut, the auto open), Console.js and Recorder.js (a console
// capture and a roundtrip history collected AFTER the problem are worth
// nothing) and the three leaf modules those two require. Everything else
// under devtools/ - the dialog, its fragment, the inspectors, the tabs, the
// picker, the live editor, the report - is the DEVTOOLS BUNDLE, a second
// generated script the handler serves on ?z2ui5-bundle=devtools, which
// DevTools.js loads with a <script> element the first time the tools are
// opened (rule 13: a file of the same origin, allowed by script-src 'self',
// no eval and no inline script). The split halves nothing by accident: a
// module of the shell that named a deferred one as a sap.ui.define
// dependency would be fetched from the ICF node - which answers every GET
// with the page - and would take the whole component down, so the
// generation refuses it (assertNoEagerDependencyOnDeferred).
const DEVTOOLS_DIR = "devtools/";
const DEVTOOLS_EAGER = new Set([
  "devtools/DevTools.js",
  "devtools/Console.js",
  "devtools/Recorder.js",
  // required by Console and Recorder
  "devtools/Persist.js",
  "devtools/Format.js",
  "devtools/Diff.js",
]);
function isDeferredDevtools(relPath) {
  return relPath.startsWith(DEVTOOLS_DIR) && !DEVTOOLS_EAGER.has(relPath);
}

// The custom controls are the THIRD bundle: every file under cc/, served on
// ?z2ui5-bundle=cc (z2ui5_cl_ui5_http_handler=>_http_get_cc) and loaded by
// z2ui5/core/CustomControls with a <script> element before the first view
// that names one is built. They are about a quarter of the frontend, and
// about one app in forty uses one (measured 2026-11-23 on abap2UI5/
// samples-controls and samples-stack: 19 of 763 apps) - every other page
// paid for them on its cold start. None of them is eager: a control enters
// a page through a view, and the view is what the load waits for. The one
// module of the shell that talks to a control (Component.js, cc/Dirty)
// probes it with the one-id sap.ui.require and finds nothing where no view
// brought the bundle in - which is exactly when there is nothing to tell
// it.
//
// The frontend bundle says that the controls are a bundle of their own, and
// which: the digest of the cc bundle's text goes into the tail
// (bundle/tail/embed.js) in place of CC_VERSION_TOKEN at generation time.
// z2ui5/core/CustomControls asks for the bundle under that version, so the
// handler may let a browser keep it without asking again - and a frontend
// that came as single files (no tail, the UI5 loader finds cc/<Name>.js
// itself) asks for no bundle at all.
const CC_DIR = "cc/";
const CC_VERSION_TOKEN = "@z2ui5-cc-version@";
function isDeferredCc(relPath) {
  return relPath.startsWith(CC_DIR);
}

// The bundle a file of bundle/webapp is delivered in besides the frontend
// bundle: "devtools", "cc", or null for the frontend bundle itself.
function deferredBundleOf(relPath) {
  if (isDeferredDevtools(relPath)) return "devtools";
  if (isDeferredCc(relPath)) return "cc";
  return null;
}

// The sap.ui.define dependency arrays of a module's source: every quoted
// module id inside the first array literal after `sap.ui.define(`.
const DEFINE_DEPS = /sap\.ui\.define\(\s*\[([^\]]*)\]/;
function defineDependencies(source) {
  const match = DEFINE_DEPS.exec(source);
  if (!match) return [];
  return [...match[1].matchAll(/["']([^"']+)["']/g)].map((m) => m[1]);
}

// How a module outside a deferred bundle has to reach one inside it - the
// second half of the guard's message.
const DEFERRED_REMEDY = {
  devtools:
    "a module of the devtools bundle - " +
    "a module outside the bundle (the inline preload, the embed bundle) must reach it " +
    "lazily through DevTools.js, or the file has to join DEVTOOLS_EAGER in " +
    "tools/app2abap/trans2abap.js",
  cc:
    "a module of the custom controls bundle - " +
    "nothing outside bundle/webapp/cc/ may depend on a control: a view brings the " +
    "bundle in (core/CustomControls.js), and a module that has to talk to a control " +
    "probes it with sap.ui.require( id ) and takes undefined for an answer",
};

// Guard 4: no module may name, as a sap.ui.define dependency, a module of a
// deferred bundle it is not part of itself - see DEVTOOLS_EAGER and CC_DIR.
// The dependency would be asked of the loader before that bundle is in, and
// the loader would fetch it from the node, which answers every GET with the
// page. That holds for the frontend bundle's modules and between the two
// deferred bundles alike (the developer tools open without the controls,
// a view with a control builds without the tools). `sources` maps the
// relative path of every .js file to its source text.
function assertNoEagerDependencyOnDeferred(sources) {
  for (const [relPath, source] of sources) {
    const own = deferredBundleOf(relPath);
    for (const dep of defineDependencies(source)) {
      if (!dep.startsWith("z2ui5/")) continue;
      const depPath = `${dep.slice("z2ui5/".length)}.js`;
      const bundle = deferredBundleOf(depPath);
      if (!bundle || bundle === own) continue;
      throw new Error(
        `${relPath}: sap.ui.define names ${dep}, ${DEFERRED_REMEDY[bundle]}`,
      );
    }
  }
}

// One preload entry as the script text carries it: a .js file as the body of
// a function, anything else as a single-quoted string literal.
function preloadEntryText({ urlPath, isJs, value }) {
  return isJs
    ? `      "${urlPath}": function(){${value}},`
    : `      "${urlPath}": '${escapeJsLiteral(value)}',`;
}

// The complete text of the inline <script> exactly as the generated get( )
// returns it - what the browser hashes against the CSP's script-src.
function inlineScript(entries) {
  return [...SCRIPT_OPEN, ...entries.map(preloadEntryText), ...SCRIPT_CLOSE]
    .map((line) => `${line}\n`)
    .join("");
}

// The complete text of a bundle script (get_bundle( ) without the embed
// module the handler appends, get_devtools( ), get_cc( )) - the validator
// of the devtools bundle and of the custom controls bundle is a digest of
// theirs.
function bundleScript(entries, open = BUNDLE_OPEN, close = BUNDLE_CLOSE) {
  return [...open, ...entries.map(preloadEntryText), ...close]
    .map((line) => `${line}\n`)
    .join("");
}

// The generated classes: one per text the node serves, and the facade the
// handler talks to. Short names - a generated name must survive the rename
// workflow (.github/workflows/build-rename.yaml), which swaps the 5-character
// `z2ui5` for a namespace of up to 10 characters, so the budget is 25, not
// ABAP's 30.
const MAX_CLASS_NAME_LENGTH = 25;
const CLASSES = {
  bundle: "z2ui5_cl_ui5f_bundle",
  cc: "z2ui5_cl_ui5f_cc",
  devtools: "z2ui5_cl_ui5f_devtools",
  page: "z2ui5_cl_ui5f_page",
  preload: "z2ui5_cl_ui5f_preload",
};

// Builds z2ui5_cl_ui5f_preload, the one class z2ui5_cl_ui5_http_handler asks:
// it hands out the generated texts and the constants taken over them at
// generation time.
//   script_hash    the SHA-256 of the page's inline script as a CSP hash
//                  source - _http_get lists it in the policy's script-src, so
//                  the script runs without 'unsafe-inline' and nothing else
//                  inline does
//   build_hash     a short digest of everything the node serves - the ETag of
//                  the page and of the bundle carries it, so a redeployed
//                  frontend with the same version constant still changes the
//                  tag
//   devtools_hash  the same for the devtools bundle
//   cc_hash        the same for the custom controls bundle - and the version
//                  the frontend asks for it by (CC_VERSION_TOKEN)
// Nothing configurable may enter a text: an exit value in it would make the
// digests a runtime question.
function buildPreloadClass(buildHash, scriptHash, devtoolsHash, ccHash) {
  return `* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* The texts the HTTP service serves, generated from bundle/webapp/ and
* app_source/webapp/ by tools/app2abap/trans2abap.js. Change the sources
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS ${CLASSES.preload} DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " a digest of everything the node serves a browser - the page's script
    " get( ) returns and the frontend bundle get_bundle( ) returns, which
    " names the custom controls bundle by its own digest - fixed
    " at generation time. Part of the ETag of
    " the page and of the bundle (z2ui5_cl_ui5_http_handler=>_get_etag)
    CONSTANTS build_hash TYPE string VALUE '${buildHash}'.

    " the digest of the script get( ) returns as a CSP hash source, without
    " the quotes around it:
    " z2ui5_cl_ui5_http_handler=>_http_get lists it in the policy's
    " script-src, so this one inline script runs without 'unsafe-inline'.
    " It is the SHA-256 of get( ) byte for byte - a script that differs by one
    " character does not run at all, which the browser e2e legs would show
    CONSTANTS script_hash TYPE string VALUE '${scriptHash}'.

    " a digest of the devtools bundle get_devtools( ) returns - the files
    " of the developer tools the frontend bundle does not carry. The ETag of
    " that bundle carries it (z2ui5_cl_ui5_http_handler=>_http_get_devtools)
    CONSTANTS devtools_hash TYPE string VALUE '${devtoolsHash}'.

    " a digest of the custom controls bundle get_cc( ) returns. The
    " frontend bundle carries it too (the ccBundle of its z2ui5/embed
    " module) and asks for the controls by it - as ?z2ui5-bundle=cc with
    " this value as z2ui5-version, which lets a browser keep the answer
    " (z2ui5_cl_ui5_http_handler=>_is_bundle_versioned). The ETag of that
    " bundle carries it as well
    CONSTANTS cc_hash TYPE string VALUE '${ccHash}'.

    " the one inline script of the GET page: the page's minimal app (a
    " component with one view) and the embed control that view holds
    " (z2ui5.embed.Container) as a preload, and the call that starts it.
    " Nothing of the frontend - the control loads it from the node, as
    " get_bundle( )
    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

    " the frontend as a script of its own, for a page that embeds the
    " component - the GET page of this node included:
    " sap.ui.require.preload( ) and nothing else - no function
    " around it, no start (z2ui5_cl_ui5_http_handler=>_http_get_bundle)
    CLASS-METHODS get_bundle
      RETURNING
        VALUE(result) TYPE string.

    " the developer tools as a script of the same shape: the dialog, its
    " fragment, the inspectors - everything under devtools/ the frontend
    " bundle does not carry (tools/app2abap/trans2abap.js, DEVTOOLS_EAGER).
    " Served on ?z2ui5-bundle=devtools
    " (z2ui5_cl_ui5_http_handler=>_http_get_devtools) and loaded by
    " z2ui5/devtools/DevTools.js when the tools are opened
    CLASS-METHODS get_devtools
      RETURNING
        VALUE(result) TYPE string.

    " the custom controls as a script of the same shape: every file of
    " bundle/webapp/cc/, which the frontend bundle does not carry.
    " Served on ?z2ui5-bundle=cc
    " (z2ui5_cl_ui5_http_handler=>_http_get_cc) and loaded by
    " z2ui5/core/CustomControls before the first view that names a
    " control is built
    CLASS-METHODS get_cc
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ${CLASSES.preload} IMPLEMENTATION.

  METHOD get.

    result = ${CLASSES.page}=>get( ).

  ENDMETHOD.

  METHOD get_bundle.

    result = ${CLASSES.bundle}=>get( ).

  ENDMETHOD.

  METHOD get_devtools.

    result = ${CLASSES.devtools}=>get( ).

  ENDMETHOD.

  METHOD get_cc.

    result = ${CLASSES.cc}=>get( ).

  ENDMETHOD.

ENDCLASS.
`;
}

// Function to recursively get all files in a directory
function getAllFiles(dirPath, arrayOfFiles) {
  const files = fs.readdirSync(dirPath);

  arrayOfFiles = arrayOfFiles || [];

  files.forEach((file) => {
    const filePath = path.join(dirPath, file);
    if (fs.statSync(filePath).isDirectory()) {
      arrayOfFiles = getAllFiles(filePath, arrayOfFiles);
    } else {
      arrayOfFiles.push(filePath);
    }
  });

  return arrayOfFiles;
}

// The texts the node serves, put together from the sources: the page's
// inline script, the frontend bundle (with its tail, the node-path token
// still in it), the devtools bundle and the custom controls bundle. main( )
// writes them into src/01/03;
// the live dev server (node/srv/live.mjs) answers a bundle request with them
// straight from the working tree - with `strip: false`, the comments stay
// and no Prettier is needed.
async function buildTexts({ strip = true } = {}) {
  // The frontend: every file of bundle/webapp, sorted so the generation
  // order (and the output) does not depend on the filesystem's readdir
  // order.
  const preloadEntries = [];
  const devtoolsEntries = [];
  const ccEntries = [];
  const entriesOf = { devtools: devtoolsEntries, cc: ccEntries };
  // the .js sources by relative path, for guard 4
  const jsSources = new Map();
  for (const file of getAllFiles(sourceDir).sort()) {
    const relPath = path.relative(sourceDir, file).split(path.sep).join("/");
    if (file.endsWith(".js")) jsSources.set(relPath, await readFile(file));
    const { isJs, value } = await readSource(
      file,
      `bundle/webapp/${relPath}`,
      strip,
    );
    (entriesOf[deferredBundleOf(relPath)] || preloadEntries).push({
      urlPath: `z2ui5/${relPath}`,
      isJs,
      value,
    });
  }

  // The page's own sources (PAGE_SOURCES)
  const pageEntries = [];
  for (const { source, urlPath } of PAGE_SOURCES) {
    const file = path.join(repoDir, source);
    if (!fs.existsSync(file)) {
      throw new Error(`${source} is missing - the GET page carries it`);
    }
    const { isJs, value } = await readSource(file, source, strip);
    pageEntries.push({ urlPath, isJs, value });
  }

  // Sorted for a stable output. Plain code-unit comparison, not
  // localeCompare: the collation of localeCompare depends on the host
  // locale/ICU build, and the sort order is committed output (src/01/03).
  const byUrlPath = (a, b) =>
    a.urlPath < b.urlPath ? -1 : a.urlPath > b.urlPath ? 1 : 0;
  preloadEntries.sort(byUrlPath);
  pageEntries.sort(byUrlPath);
  devtoolsEntries.sort(byUrlPath);
  ccEntries.sort(byUrlPath);
  assertNoEagerDependencyOnDeferred(jsSources);

  // The texts, as the node serves them
  const pageText = inlineScript(pageEntries);
  // ... the custom controls bundle first: the frontend bundle names it by
  // its digest. 16 hex characters like the other two validators - it is a
  // cache key, not a security digest
  const ccText = bundleScript(ccEntries, CC_OPEN, CC_CLOSE);
  const ccHash = crypto
    .createHash("sha256")
    .update(ccText, "utf8")
    .digest("hex")
    .slice(0, 16);
  // ... the frontend bundle with its tail behind the preload: the
  // z2ui5/embed module a host finds the bundle by (BUNDLE_TAIL)
  const tail = await readSource(
    path.join(repoDir, BUNDLE_TAIL),
    BUNDLE_TAIL,
    strip,
  );
  if (!tail.value.includes(NODE_PATH_TOKEN)) {
    throw new Error(
      `${BUNDLE_TAIL}: ${NODE_PATH_TOKEN} not found - the handler writes the node's path there`,
    );
  }
  if (!tail.value.includes(CC_VERSION_TOKEN)) {
    throw new Error(
      `${BUNDLE_TAIL}: ${CC_VERSION_TOKEN} not found - the version of the custom controls bundle goes there`,
    );
  }
  const bundleText =
    bundleScript(preloadEntries) +
    tail.value.replace(CC_VERSION_TOKEN, () => ccHash);
  const devtoolsText = bundleScript(
    devtoolsEntries,
    DEVTOOLS_OPEN,
    DEVTOOLS_CLOSE,
  );
  return {
    pageText,
    bundleText,
    devtoolsText,
    ccText,
    ccHash,
    pageEntries,
    preloadEntries,
    devtoolsEntries,
    ccEntries,
  };
}

// Main function to read the source files and create new target files
// One embedded source: read, guarded, and - a .js - minified (minifyJs).
// `label` is how the file is named in an error, `asciiName` the name the
// 7-bit guard reports it under.
async function readSource(file, label, strip = true) {
  let content = await readFile(file);
  const isJs = file.endsWith(".js");
  assertSevenBitAscii(content, label);
  if (isJs && strip) content = minifyJs(content, label);
  else if (!isJs) assertNoLossInSpecialFile(content, label, label);
  return { isJs, content, value: embeddedValue(content, !isJs) };
}

// Main function to read the source files and create new target files
async function main() {
  try {
    // the control is a pinned checkout - materialised (or confirmed) first,
    // so the copy the backend serves is always the pinned one
    require("child_process").execFileSync(
      process.execPath,
      [path.join(repoDir, "node/setup/fetch-deps.mjs")],
      { stdio: ["ignore", "ignore", "inherit"] },
    );
    // Everything is generated into memory FIRST and written only once the
    // whole set is built: a source file with a non-ASCII character or a
    // module that breaks the devtools split leaves the committed tree as it
    // was, instead of wiped and half-regenerated.
    const outputs = [];
    const emit = (filePath, content) => outputs.push({ filePath, content });
    const emitClass = (className, abap, text) => {
      if (className.length > MAX_CLASS_NAME_LENGTH) {
        throw new Error(
          `class name '${className}' is ${className.length} chars (max ${MAX_CLASS_NAME_LENGTH})`,
        );
      }
      emit(path.join(targetDir, `${className}.clas.abap`), abap);
      emit(
        path.join(targetDir, `${className}.clas.xml`),
        `\uFEFF${xmlTemplate(className, text)}`,
      );
    };

    // The initial XML file with BOM
    emit(path.join(targetDir, "package.devc.xml"), initialXMLContent);

    const {
      pageText,
      bundleText,
      devtoolsText,
      ccText,
      ccHash,
      pageEntries,
      preloadEntries,
      devtoolsEntries,
      ccEntries,
    } = await buildTexts();

    // One SHA-256 over the script text the page will carry, UTF-8 like the
    // page (the text is 7-bit ASCII anyway, see assertSevenBitAscii) - the
    // bytes a browser hashes to decide whether the script may run.
    const scriptHash = `sha256-${crypto
      .createHash("sha256")
      .update(pageText, "utf8")
      .digest("base64")}`;
    // The validator covers everything the node serves a browser, not the
    // page's script alone: the bundle is the frontend, and its ETag carries
    // this hash as the page's does. The custom controls bundle is covered
    // through the bundle's tail, which carries that bundle's digest. 16 hex characters: a validator, not a
    // security digest, and the tag travels in every GET response header
    const buildHash = crypto
      .createHash("sha256")
      .update(pageText, "utf8")
      .update(bundleText, "utf8")
      .digest("hex")
      .slice(0, 16);
    // the devtools bundle's own validator - served as a file, no CSP
    // hash is taken over it, the ETag is what it is for
    const devtoolsHash = crypto
      .createHash("sha256")
      .update(devtoolsText, "utf8")
      .digest("hex")
      .slice(0, 16);

    const sourcesOf = (entries) =>
      `${entries.length} files: ${entries.map((e) => e.urlPath).join(", ")}`;
    // the list of sources in a class header, wrapped to the comment width
    const wrap = (text) =>
      text.match(/.{1,68}(?:\s|$)|\S+/g).map((l) => l.trim());
    emitClass(
      CLASSES.bundle,
      abapTextClass(CLASSES.bundle, bundleText, [
        "The frontend bundle - what GET <node>?z2ui5-bundle answers with,",
        "once the handler has written the node's path into its tail. Source:",
        "bundle/webapp/, every file outside the devtools bundle and the",
        "custom controls bundle, and bundle/tail/embed.js behind them.",
        ...wrap(sourcesOf(preloadEntries)),
      ]),
      "abap2UI5 - frontend bundle",
    );
    emitClass(
      CLASSES.devtools,
      abapTextClass(CLASSES.devtools, devtoolsText, [
        "The devtools bundle - what GET <node>?z2ui5-bundle=devtools answers",
        "with. Source: bundle/webapp/devtools/, the files loaded on demand.",
        ...wrap(sourcesOf(devtoolsEntries)),
      ]),
      "abap2UI5 - devtools bundle",
    );
    emitClass(
      CLASSES.cc,
      abapTextClass(CLASSES.cc, ccText, [
        "The custom controls bundle - what GET <node>?z2ui5-bundle=cc answers",
        "with. Source: bundle/webapp/cc/, loaded when a view names a control.",
        ...wrap(sourcesOf(ccEntries)),
      ]),
      "abap2UI5 - custom controls bundle",
    );
    emitClass(
      CLASSES.page,
      abapTextClass(CLASSES.page, pageText, [
        "The one inline script of the page a GET answers with: the minimal",
        "app and the embed control. Source: app_source/webapp/.",
        ...wrap(sourcesOf(pageEntries)),
      ]),
      "abap2UI5 - page script",
    );
    emitClass(
      CLASSES.preload,
      buildPreloadClass(buildHash, scriptHash, devtoolsHash, ccHash),
      "abap2UI5 - preload mapping",
    );

    // The BSP first: app2bsp refuses a folder that cannot become one (a
    // line over 255 characters, a file name the system rejects) before it
    // writes anything, so a refusal leaves both generated trees as they were.
    // Into a folder of its own, which takes the place of the committed one
    // in the write phase below - app2bsp writes into an empty folder only.
    // The app as git has it plus the control where the manifest registers
    // it - what `ui5 build` makes of app_source with the control from npm.
    const { app2bsp, checkBspFolder } = await import("../bsp/index.mjs");
    const bspWork = fs.mkdtempSync(path.join(os.tmpdir(), "z2ui5-bsp-"));
    const manifest = fs.readFileSync(
      path.join(repoDir, pageDir, "manifest.json"),
      "utf8",
    );
    if (!manifest.includes(`"z2ui5.embed": "./${CONTROL_PATH}"`)) {
      throw new Error(
        `${pageDir}/manifest.json registers z2ui5.embed elsewhere than ./${CONTROL_PATH} - the BSP carries the control there`,
      );
    }
    const bspApp = path.join(bspWork, "webapp");
    fs.cpSync(path.join(repoDir, pageDir), bspApp, { recursive: true });
    fs.mkdirSync(path.join(bspApp, CONTROL_PATH), { recursive: true });
    fs.copyFileSync(
      path.join(repoDir, CONTROL),
      path.join(bspApp, CONTROL_PATH, "Container.js"),
    );
    const bsp = app2bsp({
      webapp: bspApp,
      target: path.join(bspWork, "bsp"),
      ...BSP,
    });
    // ... and what it wrote is checked as stored - the page format pads
    // every line, and a .js page has to parse with the padding in it
    const stored = checkBspFolder(path.join(bspWork, "bsp"));
    if (stored.problems.length) {
      throw new Error(`BSP ${BSP.name}:\n  ${stored.problems.join("\n  ")}`);
    }

    // Every guard has passed and every byte is in hand - only now is the
    // committed tree replaced.
    fs.rmSync(targetDir, { recursive: true, force: true });
    fs.mkdirSync(targetDir, { recursive: true });
    for (const { filePath, content } of outputs) {
      await createFileInTargetDir(filePath, content);
    }
    fs.rmSync(bspDir, { recursive: true, force: true });
    fs.cpSync(path.join(bspWork, "bsp"), bspDir, { recursive: true });
    fs.rmSync(bspWork, { recursive: true, force: true });
    console.log(`${outputs.length} file(s) written to ${targetDir}`);
    console.log(`BSP ${BSP.name}: ${bsp.pages.length} page(s) written to ${bspDir}`);
  } catch (error) {
    // Signal failure so CI (check_app2abap.yaml, autofix.yaml) does not
    // treat a broken generation run as success and commit a partial
    // src/01/03. Since the write phase above is the last thing main( )
    // does, a failure reported here also means the committed tree was
    // never touched.
    console.error("Error:", error.message);
    process.exitCode = 1;
  }
}

// Run the main function - only as the script itself (npm run auto_app2abap):
// node/tests/trans2abap.spec.js requires the module for its pure helpers and
// must not regenerate src/01/03 by doing so.
if (require.main === module) {
  main();
}

module.exports = {
  buildTexts,
  NODE_PATH_TOKEN,
  abapTextClass,
  embeddedValue,
  minifyJs,
  assertSameProgram,
  isDeferredDevtools,
  isDeferredCc,
  deferredBundleOf,
  CC_VERSION_TOKEN,
  defineDependencies,
  assertNoEagerDependencyOnDeferred,
  DEVTOOLS_EAGER,
};
