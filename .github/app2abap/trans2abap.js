const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const abapClassTemplate = require('./abapClassTemplate');
const xmlTemplate = require('./abapXMLTemplate');

// Define source and target directories
const sourceDir = path.join(__dirname, '../../app/webapp');
const targetDir = path.join(__dirname, '../../src/01/03');

// The interface that defines the release. Its version constant is stamped into
// the generated build identity so a frontend artefact can name the abap2UI5
// release it came from.
const versionSourceFile = path.join(__dirname, '../../src/02/z2ui5_if_app.intf.abap');

// The generated build identity, in its two forms: a UI5 module that ships to
// the browser with the rest of app/webapp, and an ABAP class the backend reads
// to learn what the frontend it EMBEDS says about itself. Both carry the same
// two values.
//
// Why this exists: the backend arrives via abapGit, the BSP frontend is
// installed separately (abap2UI5/frontend -> build_* -> BSP branches), and the
// browser caches Component-preload.js on top of that. Three copies that can
// drift, with no symptom until a view breaks. The pair below gives each copy a
// name, which is what makes the drift observable - see z2ui5_cl_ui5_handler
// (fills the response) and app/webapp/core/Server.js (compares and warns).
//
// The stamp is a content fingerprint, deliberately not a build timestamp: the
// check_app2abap gate re-runs this generation and fails on any diff, so
// anything time-based here would fail the gate on every run. A hash over the
// sources is stable for the same content, which is also the question actually
// being asked ("is the same frontend running?").
const BUILD_MODULE_REL_PATH = 'core/Build.js';
const BUILD_CLASS_NAME = 'z2ui5_cl_ui5f_build';

// Length of the fingerprint kept from the sha256 digest. 12 hex chars = 48
// bits: far past any accidental collision between two builds of one repository,
// and short enough to read out of a console message or a popup field.
const BUILD_HASH_LENGTH = 12;

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

// Function to format the content into an ABAP class method
function formatAsAbapClass(content, className, isSpecialFile, sourcePath) {
    const lines = content.split('\n');
    const formattedLines = lines.map((line, index) => {
        line = line.replace(/\s+$/, ''); // Remove trailing spaces

        // Guard 1: the frontend source is embedded verbatim into an ABAP string
        // constant, which abaplint checks with the 7bit_ascii rule. A non-ASCII
        // byte (smart quote, ellipsis, arrow, ...) breaks generation/lint
        // downstream with a confusing error, so fail here at the exact source
        // line instead. Runtime non-ASCII must be built via String.fromCharCode
        // / entity decoding (see AGENTS.md rule 14).
        const nonAscii = line.match(/[^\x00-\x7F]/);
        if (nonAscii) {
            throw new Error(
                `${className} line ${index + 1}: non-ASCII character ${JSON.stringify(nonAscii[0])} ` +
                `(code ${nonAscii[0].codePointAt(0)}) - frontend source must be 7-bit ASCII: ${line.trim()}`,
            );
        }

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
    'devtools/DeveloperTools.fragment.xml': 'dtools_xml',
    'devtools/DeveloperTools.js': 'dtools_js',
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
            `CLASS_NAME_STEMS in .github/app2abap/trans2abap.js`,
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
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
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
    " in a fragment (title="\{= \${/appName} ? 'a' : 'b' }") writes them, and so
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

// Reads the release from the version constant of z2ui5_if_app. Parsed rather
// than taken from package.json: AGENTS.md names the interface as the place the
// version is defined, and a frontend artefact that claims a different release
// than the backend interface would defeat the very comparison it feeds.
function readVersion() {
    const source = fs.readFileSync(versionSourceFile, 'utf-8');
    const match = /CONSTANTS\s+version\s+TYPE\s+string\s+VALUE\s+`([^`]*)`/i.exec(source);
    if (!match) {
        throw new Error(
            `could not read the version constant from ${path.relative(path.join(__dirname, '../..'), versionSourceFile)} - ` +
            `expected a line like "CONSTANTS version TYPE string VALUE \`1.2.3\`."`,
        );
    }
    return match[1];
}

// Content fingerprint over the frontend sources. Path and content both go in,
// so a pure rename is a change too. The generated build module is excluded -
// it is an OUTPUT of this hash, and including it would leave the generation
// without a fixpoint (every run would produce a new hash from the previous
// run's hash). Files are read as buffers so the digest is over the bytes on
// disk, not over a decoded string.
function computeFrontendHash(files) {
    const digest = crypto.createHash('sha256');
    const entries = files
        .map(file => ({ relPath: path.relative(sourceDir, file).split(path.sep).join('/'), file }))
        .filter(({ relPath }) => relPath !== BUILD_MODULE_REL_PATH)
        // readdir order is not part of the identity - sort so the same tree
        // always produces the same fingerprint.
        .sort((a, b) => a.relPath.localeCompare(b.relPath));
    for (const { relPath, file } of entries) {
        const content = fs.readFileSync(file);
        // The length between path and content keeps the stream unambiguous:
        // without it, moving bytes from one file's tail into the next file's
        // name would hash the same.
        digest.update(`${relPath}\n${content.length}\n`);
        digest.update(content);
    }
    return digest.digest('hex').slice(0, BUILD_HASH_LENGTH);
}

// The browser-side half of the build identity. Written into app/webapp so it
// travels with every delivery path the frontend has: embedded into src/01/03
// by this script, and mirrored to abap2UI5/frontend (and from there into the
// BSP branches) by create_frontend.yaml.
//
// Formatted the way prettier would (app/.prettierrc: 2 spaces, double quotes,
// semicolons, trailing commas) because `npm run app2abap` runs the formatter
// BEFORE this generation - a file that prettier would rewrite is a diff the
// next run produces out of nowhere, and the check_app2abap gate fails on it.
function buildIdentityModule(version, hash) {
    return `// =====================================================================
// GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
// Build identity of the frontend artefacts, generated from app/webapp/ by
// .github/app2abap/trans2abap.js. Run 'npm run app2abap' to regenerate;
// the check_app2abap CI gate fails any manual edit here.
// =====================================================================
//
// What this is for: a running abap2UI5 app is assembled from copies that are
// installed separately and can drift apart - the backend (abapGit), the
// frontend the backend embeds (src/01/03, generated from these same sources),
// and the BSP frontend (abap2UI5/frontend), with the browser's cache on top.
// This module is what the copy in the browser answers with when core/Server.js
// asks which build it is; the backend sends the same two values for its own
// copy on the first roundtrip of a page load.
sap.ui.define([], () => {
  "use strict";

  return {
    // abap2UI5 release these artefacts were generated from - the version
    // constant of z2ui5_if_app at generation time.
    VERSION: "${version}",

    // Fingerprint over app/webapp/** (this file excluded). Two copies with
    // the same hash ARE the same frontend; a different hash under the same
    // VERSION is the signature of a stale cache or an un-redeployed BSP.
    HASH: "${hash}",
  };
});
`;
}

// The ABAP-side half: what the EMBEDDED frontend (src/01/03) says about itself,
// as constants the backend can read without parsing JavaScript. Consumed by
// z2ui5_cl_ui5_handler to fill the response and by z2ui5_cl_ui5_app_start to
// show the build in the system-information popup.
function buildIdentityClass(version, hash) {
    return `* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Build identity of the embedded frontend, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
*
* The same two values ship to the browser in app/webapp/core/Build.js, so
* the frontend that is actually RUNNING can be compared against the one
* this backend embeds - see z2ui5_cl_ui5_handler=>main_end.
* =====================================================================
CLASS ${BUILD_CLASS_NAME} DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " abap2UI5 release these frontend artefacts were generated from.
    CONSTANTS version TYPE string VALUE \`${version}\`.

    " Fingerprint over app/webapp/** (core/Build.js excluded).
    CONSTANTS hash TYPE string VALUE \`${hash}\`.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ${BUILD_CLASS_NAME} IMPLEMENTATION.
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
        // Delete the target directory if it exists
        fs.rmSync(targetDir, { recursive: true, force: true });

        // Recreate the target directory
        fs.mkdirSync(targetDir, { recursive: true });

        // Create the initial XML file with BOM
        const initialXMLFilePath = path.join(targetDir, 'package.devc.xml');
        await createFileInTargetDir(initialXMLFilePath, initialXMLContent);
        console.log(`Initial XML file created successfully at: ${initialXMLFilePath}`);

        // The build identity is written into app/webapp BEFORE the walk below,
        // so the generated module is picked up like any other frontend file:
        // it gets its own embedded class and its own preload entry, and needs
        // no special case anywhere downstream. Its own content is excluded
        // from the fingerprint (see computeFrontendHash).
        const version = readVersion();
        const frontendHash = computeFrontendHash(getAllFiles(sourceDir));
        const buildModulePath = path.join(sourceDir, ...BUILD_MODULE_REL_PATH.split('/'));
        await createFileInTargetDir(buildModulePath, buildIdentityModule(version, frontendHash));
        console.log(`Build identity module created successfully at: ${buildModulePath} (${version} / ${frontendHash})`);

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
            const abapClassContent = formatAsAbapClass(sourceContent, className, isSpecialFile, relPath);

            const targetFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.abap`);
            await createFileInTargetDir(targetFilePath, abapClassContent);
            console.log(`Target file created successfully at: ${targetFilePath}`);

            const xmlContent = xmlTemplate(className, `abap2UI5 - ${path.basename(file)}`);
            const xmlFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.xml`);
            await createFileInTargetDir(xmlFilePath, `\uFEFF${xmlContent}`);
            console.log(`XML file created successfully at: ${xmlFilePath}`);

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
        preloadEntries.sort((a, b) => a.urlPath.localeCompare(b.urlPath));
        const preloadFilePath = path.join(targetDir, 'z2ui5_cl_ui5f_preload.clas.abap');
        await createFileInTargetDir(preloadFilePath, buildPreloadClass(preloadEntries));
        console.log(`Preload class created successfully at: ${preloadFilePath}`);
        const preloadXmlPath = path.join(targetDir, 'z2ui5_cl_ui5f_preload.clas.xml');
        await createFileInTargetDir(preloadXmlPath, `\uFEFF${xmlTemplate('z2ui5_cl_ui5f_preload', 'abap2UI5 - preload mapping')}`);
        console.log(`Preload XML created successfully at: ${preloadXmlPath}`);

        // The ABAP-side build identity. Not a resource the browser loads, so
        // it carries no preload entry - the backend reads its constants.
        const buildClassPath = path.join(targetDir, `${BUILD_CLASS_NAME}.clas.abap`);
        await createFileInTargetDir(buildClassPath, buildIdentityClass(version, frontendHash));
        console.log(`Build identity class created successfully at: ${buildClassPath}`);
        const buildClassXmlPath = path.join(targetDir, `${BUILD_CLASS_NAME}.clas.xml`);
        await createFileInTargetDir(buildClassXmlPath, `\uFEFF${xmlTemplate(BUILD_CLASS_NAME, 'abap2UI5 - build identity')}`);
        console.log(`Build identity XML created successfully at: ${buildClassXmlPath}`);
    } catch (error) {
        // Signal failure so CI (create_app2abap.yaml) does not treat a broken
        // generation run as success and commit a partial src/01/03.
        console.error('Error:', error.message);
        process.exitCode = 1;
    }
}

// Run the main function
main();
