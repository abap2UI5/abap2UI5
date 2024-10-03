const fs = require('fs');
const path = require('path');

const sourceDir = './app/webapp';
const staticDir = './static';
const targetDir = './src/02';
const prefix = 'z2ui5.wapa.';

function generateTargetFileName(sourcePath, baseDir) {
    const relativePath = path.relative(baseDir, sourcePath);
    const fileName = prefix + relativePath.replace(/\//g, '_-').replace(/\\/g, '_-').toLowerCase();
    return fileName;
}

function copyFilesRecursively(source, target, baseDir, renameFiles = true) {
    fs.readdir(source, { withFileTypes: true }, (err, entries) => {
        if (err) {
            console.error('Fehler beim Lesen des Verzeichnisses:', err);
            return;
        }

        entries.forEach(entry => {
            const sourcePath = path.join(source, entry.name);
            const targetFileName = renameFiles ? generateTargetFileName(sourcePath, baseDir) : entry.name;
            const targetPath = path.join(target, targetFileName);

            if (entry.isDirectory()) {
                // Rekursiver Aufruf für Unterordner
                copyFilesRecursively(sourcePath, target, baseDir, renameFiles);
            } else if (entry.isFile()) {
                // Lese die Quelldatei
                fs.readFile(sourcePath, 'utf8', (err, data) => {
                    if (err) {
                        console.error(`Fehler beim Lesen der Quelldatei ${entry.name}:`, err);
                        return;
                    }

                    // Erstelle den Zielordner, falls er nicht existiert
                    fs.mkdir(path.dirname(targetPath), { recursive: true }, (err) => {
                        if (err) {
                            console.error('Fehler beim Erstellen des Zielordners:', err);
                            return;
                        }

                        // Schreibe den Inhalt in die Zieldatei
                        fs.writeFile(targetPath, data, 'utf8', (err) => {
                            if (err) {
                                console.error(`Fehler beim Schreiben der Zieldatei ${entry.name}:`, err);
                                return;
                            }
                            console.log(`Datei ${entry.name} erfolgreich kopiert als ${targetFileName}.`);
                        });
                    });
                });
            }
        });
    });
}

function deleteFilesRecursively(directory) {
    if (fs.existsSync(directory)) {
        fs.readdirSync(directory).forEach((file) => {
            const curPath = path.join(directory, file);
            if (fs.lstatSync(curPath).isDirectory()) {
                deleteFilesRecursively(curPath);
            } else {
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(directory);
    }
}

// Lösche alle Dateien im Zielverzeichnis
deleteFilesRecursively(targetDir);

// Erstelle das Zielverzeichnis, falls es nicht existiert
fs.mkdir(targetDir, { recursive: true }, (err) => {
    if (err) {
        console.error('Fehler beim Erstellen des Zielverzeichnisses:', err);
        return;
    }

    // Starte den Kopiervorgang für den Quellordner
    copyFilesRecursively(sourceDir, targetDir, sourceDir);

    // Starte den Kopiervorgang für den statischen Ordner ohne Umbenennung
    copyFilesRecursively(staticDir, targetDir, staticDir, false);
});