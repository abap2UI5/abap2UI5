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
        let formattedLine = `             \`${line.replace(/`/g, '``')}\` && ${isSpecialFile ? '' : '|\\n|  &&'}`;
        formattedLine = formattedLine.replace(/&&\s+$/, '&&'); // Remove trailing spaces after &&
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

// Function to generate a class name from a file path
function generateClassName(filePath) {
    const relativePath = path.relative(sourceDir, filePath);
    const parts = relativePath.split(path.sep);
    const fileName = parts.pop().split('.');
    if (fileName.length > 2) {
        fileName.splice(1, 1); // Remove the middle part
    }
    let className = `z2ui5_cl_app_${fileName.join('_').toLowerCase()}`;
    // ABAP object names are limited to 30 characters. Shorten the stem but
    // keep the extension suffix so the kind of file stays recognizable
    // (e.g. SmartMultiInputExt.js -> z2ui5_cl_app_smartmultiinpu_js).
    // The collision check in main() catches any ambiguity this introduces.
    if (className.length > 30) {
        const suffix = `_${fileName[fileName.length - 1].toLowerCase()}`;
        const stem = `z2ui5_cl_app_${fileName.slice(0, -1).join('_').toLowerCase()}`;
        className = stem.substring(0, 30 - suffix.length) + suffix;
    }
    return className;
}

// Builds the generated z2ui5_cl_app_preload class. It returns the
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
    return `CLASS z2ui5_cl_app_preload DEFINITION
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


CLASS z2ui5_cl_app_preload IMPLEMENTATION.

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
        // z2ui5_cl_app_foo_js), so duplicate basenames silently overwrite
        // each other. Fail fast instead.
        const seenClassNames = new Map();
        for (const file of files) {
            const cn = generateClassName(file);
            if (seenClassNames.has(cn)) {
                throw new Error(
                    `class name collision: ${file} and ${seenClassNames.get(cn)} both map to ${cn}`,
                );
            }
            seenClassNames.set(cn, file);
        }

        for (const file of files) {
            let sourceContent = await readFile(file);
            console.log(`Source file content fetched successfully for ${file}.`);

            const className = generateClassName(file);
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
        const preloadFilePath = path.join(targetDir, 'z2ui5_cl_app_preload.clas.abap');
        await createFileInTargetDir(preloadFilePath, buildPreloadClass(preloadEntries));
        console.log(`Preload class created successfully at: ${preloadFilePath}`);
        const preloadXmlPath = path.join(targetDir, 'z2ui5_cl_app_preload.clas.xml');
        await createFileInTargetDir(preloadXmlPath, `\uFEFF${xmlTemplate('z2ui5_cl_app_preload', 'abap2UI5 - preload mapping')}`);
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
