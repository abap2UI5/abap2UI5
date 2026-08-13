const fs = require('fs');
const path = require('path');
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
    <CTEXT>abap2UI5 - app (generated)</CTEXT>
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
function formatAsAbapClass(content, className, isSpecialFile) {
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
    return abapClassTemplate(className, formattedLines.join('\n'));
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
    'core/DeveloperTools.fragment.xml': 'dtools_xml',
    'core/DeveloperTools.js': 'dtools_js',
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
        if (isStyleCss) {
            return `|      "${urlPath}": '{ styles_css }',| && |\\n|`;
        }
        if (isJs) {
            const suffix = isComponent ? `{ custom_js }` : '';
            return `|      "${urlPath}": function()\\{{ ${className}=>get( ) }${suffix}\\},| && |\\n|`;
        }
        return `|      "${urlPath}": '{ ${className}=>get( ) }',| && |\\n|`;
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
ENDCLASS.


CLASS z2ui5_cl_ui5f_preload IMPLEMENTATION.

  METHOD get.

    result = ${joined}.

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
        // Delete the target directory if it exists
        fs.rmSync(targetDir, { recursive: true, force: true });

        // Recreate the target directory
        fs.mkdirSync(targetDir, { recursive: true });

        // Create the initial XML file with BOM
        const initialXMLFilePath = path.join(targetDir, 'package.devc.xml');
        await createFileInTargetDir(initialXMLFilePath, initialXMLContent);
        console.log(`Initial XML file created successfully at: ${initialXMLFilePath}`);

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
            const isSpecialFile = file.endsWith('.xml') || file.endsWith('.json') || file.endsWith('.html') || file.endsWith('.css');
            const abapClassContent = formatAsAbapClass(sourceContent, className, isSpecialFile);

            const targetFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.abap`);
            await createFileInTargetDir(targetFilePath, abapClassContent);
            console.log(`Target file created successfully at: ${targetFilePath}`);

            const xmlContent = xmlTemplate(className, `abap2UI5 - ${path.basename(file)}`);
            const xmlFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.xml`);
            await createFileInTargetDir(xmlFilePath, `\uFEFF${xmlContent}`);
            console.log(`XML file created successfully at: ${xmlFilePath}`);

            // Collect the preload entry. index.html is the standalone dev
            // page and is not preloaded by the generated GET response.
            const relPath = path.relative(sourceDir, file).split(path.sep).join('/');
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
    } catch (error) {
        // Signal failure so CI (create_app2abap.yaml) does not treat a broken
        // generation run as success and commit a partial src/01/03.
        console.error('Error:', error.message);
        process.exitCode = 1;
    }
}

// Run the main function
main();
