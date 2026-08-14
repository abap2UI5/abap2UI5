const fs = require('fs');
const path = require('path');

const sourceDir = './frontend/app/webapp';
const staticDir = './.github/app2bsp/static_files';
const targetDir = './src/02';
const prefix = 'z2ui5.wapa.';

// Pages that belong to the BSP application but have no source under
// app/webapp; their content files live in static_files.
const extraPages = ['UI5RepositoryPathMapping.xml'];
const startPage = 'index.html';

function collectFilesRecursively(dir, baseDir = dir) {
    const files = [];
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const entryPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            files.push(...collectFilesRecursively(entryPath, baseDir));
        } else if (entry.isFile()) {
            files.push(path.relative(baseDir, entryPath).split(path.sep).join('/'));
        }
    }
    return files;
}

function generateTargetFileName(relativePath) {
    return prefix + relativePath.replace(/\//g, '_-').toLowerCase();
}

function escapeXml(value) {
    return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

// BSP pages are stored on the SAP system as fixed-width 255-character lines.
// abapGit serializes them back exactly like that: every line space-padded to
// 255 characters, lines longer than that wrapped into 255-character chunks,
// LF line endings and no newline after the last line. Emit the same format so
// pulling into SAP and re-serializing produces no diff.
const bspLineWidth = 255;

function toBspPageFormat(content) {
    const lines = content.split(/\r\n|\r|\n/);
    if (lines.length > 1 && lines[lines.length - 1] === '') {
        lines.pop();
    }
    const padded = [];
    for (const line of lines) {
        if (line.length <= bspLineWidth) {
            padded.push(line.padEnd(bspLineWidth));
        } else {
            for (let offset = 0; offset < line.length; offset += bspLineWidth) {
                padded.push(line.slice(offset, offset + bspLineWidth).padEnd(bspLineWidth));
            }
        }
    }
    return padded.join('\n');
}

function buildPageItem(pageName) {
    // The start page carries MIMETYPE/IS_START_PAGE instead of PAGETYPE,
    // matching the abapGit WAPA serializer output.
    const typeLines = pageName === startPage
        ? ['      <MIMETYPE>text/html</MIMETYPE>',
           '      <IS_START_PAGE>X</IS_START_PAGE>']
        : ['      <PAGETYPE>X</PAGETYPE>'];
    return [
        '    <item>',
        '     <ATTRIBUTES>',
        '      <APPLNAME>Z2UI5</APPLNAME>',
        `      <PAGEKEY>${escapeXml(pageName.toUpperCase())}</PAGEKEY>`,
        `      <PAGENAME>${escapeXml(pageName)}</PAGENAME>`,
        ...typeLines,
        '      <LAYOUTLANGU>E</LAYOUTLANGU>',
        '      <VERSION>A</VERSION>',
        '      <LANGU>E</LANGU>',
        '     </ATTRIBUTES>',
        '    </item>',
    ].join('\n');
}

function buildWapaXml(pageNames) {
    const sorted = [...pageNames].sort((a, b) =>
        a.toUpperCase() < b.toUpperCase() ? -1 : a.toUpperCase() > b.toUpperCase() ? 1 : 0);
    // abapGit serializes XML files with a UTF-8 BOM; emit one so pulling
    // and re-pushing the repo produces no diff.
    return '\ufeff' + [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<abapGit version="v1.0.0" serializer="LCL_OBJECT_WAPA" serializer_version="v1.0.0">',
        ' <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">',
        '  <asx:values>',
        '   <ATTRIBUTES>',
        '    <APPLNAME>Z2UI5</APPLNAME>',
        '    <APPLCLAS>/UI5/CL_UI5_BSP_APPLICATION</APPLCLAS>',
        '    <APPLEXT>Z2UI5</APPLEXT>',
        '    <SECURITY>X</SECURITY>',
        '    <ORIGLANG>E</ORIGLANG>',
        '    <MODIFLANG>E</MODIFLANG>',
        '    <TEXT>test</TEXT>',
        '   </ATTRIBUTES>',
        '   <PAGES>',
        ...sorted.map(buildPageItem),
        '   </PAGES>',
        '  </asx:values>',
        ' </asx:abap>',
        '</abapGit>',
        '',
    ].join('\n');
}

fs.rmSync(targetDir, { recursive: true, force: true });
fs.mkdirSync(targetDir, { recursive: true });

const webappFiles = collectFilesRecursively(sourceDir);
for (const relativePath of webappFiles) {
    const targetFileName = generateTargetFileName(relativePath);
    const content = fs.readFileSync(path.join(sourceDir, relativePath), 'utf8');
    fs.writeFileSync(path.join(targetDir, targetFileName), toBspPageFormat(content), 'utf8');
    console.log(`Copied ${relativePath} as ${targetFileName}.`);
}

for (const fileName of fs.readdirSync(staticDir)) {
    fs.copyFileSync(path.join(staticDir, fileName), path.join(targetDir, fileName));
    console.log(`Copied static file ${fileName}.`);
}

// Generate the BSP page directory so every webapp file is registered as a
// page; files missing here would be silently skipped by the abapGit WAPA
// deserializer and never reach the target system.
const pageNames = [...webappFiles, ...extraPages];
fs.writeFileSync(path.join(targetDir, 'z2ui5.wapa.xml'), buildWapaXml(pageNames), 'utf8');
console.log(`Generated z2ui5.wapa.xml with ${pageNames.length} pages.`);
