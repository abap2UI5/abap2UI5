const fs = require('fs');
const path = require('path');
const abapClassTemplate = require('./abapClassTemplate');
const xmlTemplate = require('./abapXMLTemplate');

// Define source and target directories
const sourceDir = path.join(__dirname, '../webapp');
const targetDir = path.join(__dirname, '../../src/01/99');

// Initial XML content
const initialXMLContent = `<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DEVC>
    <CTEXT>abap2UI5 - app (generated)</CTEXT>
   </DEVC>
  </asx:values>
 </asx:abap>
</abapGit>`;

// Function to read the file content from the source directory
function readFile(filePath) {
    return fs.promises.readFile(filePath, 'utf-8');
}

// Function to create a new file in the target directory
function createFileInTargetDir(targetFilePath, content) {
    return fs.promises.writeFile(targetFilePath, content, 'utf-8');
}

// Function to format the content into an ABAP class method
function formatAsAbapClass(content, className) {
    const formattedContent = content.split('\n').map(line => {
        line = line.replace(/\s+$/, ''); // Remove trailing spaces
        let formattedLine = '';
        while (line.length > 100) {
            const lastSpaceIndex = line.substring(0, 100).lastIndexOf(' ');
            const splitIndex = lastSpaceIndex > -1 ? lastSpaceIndex : 100;
            formattedLine += `             \`${line.substring(0, splitIndex).replace(/`/g, '``')}\` && |\\n|  &&\n`;
            line = line.substring(splitIndex).trim();
        }
        formattedLine += `             \`${line.replace(/`/g, '``')}\` && |\\n|  &&`;
        return formattedLine;
    }).join('\n');
    return abapClassTemplate(className, formattedContent);
}

// Function to generate a class name from a file path
function generateClassName(filePath) {
    const relativePath = path.relative(sourceDir, filePath);
    const parts = relativePath.split(path.sep);
    const fileName = parts.pop().split('.');
    if (fileName.length > 2) {
        fileName.splice(1, 1); // Remove the middle part
    }
    const folderPath = parts.map(part => part.substring(0, 4)).join('_').toLowerCase();
    return `z2ui5_cl_app_${folderPath}_${fileName.join('_')}`;
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

// Function to delete the target directory
function deleteTargetDir(dirPath) {
    if (fs.existsSync(dirPath)) {
        fs.readdirSync(dirPath).forEach(file => {
            const curPath = path.join(dirPath, file);
            if (fs.lstatSync(curPath).isDirectory()) {
                deleteTargetDir(curPath);
            } else {
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(dirPath);
    }
}

// Main function to read the source files and create new target files
async function main() {
    try {
        // Delete the target directory if it exists
        deleteTargetDir(targetDir);

        // Recreate the target directory
        fs.mkdirSync(targetDir, { recursive: true });

        // Create the initial XML file
        const initialXMLFilePath = path.join(targetDir, 'package.devc.xml');
        await createFileInTargetDir(initialXMLFilePath, initialXMLContent);
        console.log(`Initial XML file created successfully at: ${initialXMLFilePath}`);

        const files = getAllFiles(sourceDir);

        for (const file of files) {
            const sourceContent = await readFile(file);
            console.log(`Source file content fetched successfully for ${file}.`);

            const className = generateClassName(file);
            const abapClassContent = formatAsAbapClass(sourceContent, className);

            const targetFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.abap`);
            await createFileInTargetDir(targetFilePath, abapClassContent);
            console.log(`Target file created successfully at: ${targetFilePath}`);

            const xmlContent = xmlTemplate(className, `abap2UI5 - ${path.basename(file)}`);
            const xmlFilePath = path.join(targetDir, `${className.toLowerCase()}.clas.xml`);
            await createFileInTargetDir(xmlFilePath, xmlContent);
            console.log(`XML file created successfully at: ${xmlFilePath}`);
        }
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Run the main function
main();