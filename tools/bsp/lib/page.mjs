// page.mjs - the BSP page format abapGit reads and writes, both ways.
//
// A BSP page is stored on the system as fixed-width lines of 255 characters,
// and abapGit serializes it back exactly like that: every line space-padded
// to 255, a longer line cut into 255-character chunks, LF line endings, no
// newline after the last line. Writing the same format is what makes a pull
// followed by a serialization produce no diff.
//
// The way back is lossy in three places, and all three are the system's, not
// this module's - the system stores the padded lines and nothing else:
//   - spaces at the end of a line are indistinguishable from the padding
//   - a line cut into chunks comes back as that many lines (which is why
//     app2bsp refuses a line over 255 characters instead of cutting it)
//   - whether the file ended with a newline; toFile ends every file with one

export const LINE_WIDTH = 255;

// What CL_O2_API_PAGES=>CREATE_NEW_PAGE accepts as a page name. Anything else
// is rejected with sy-subrc=2 (invalid_name), and abapGit then fails the
// import of the WHOLE BSP - a hyphen, as in Component-preload.js, is the
// common case.
export const VALID_PAGE_NAME = /^[A-Za-z0-9_./]+$/;

/** A text file as a BSP page. */
export function toPage(content) {
  const lines = content.split(/\r\n|\r|\n/);
  if (lines.length > 1 && lines[lines.length - 1] === "") {
    lines.pop();
  }
  const padded = [];
  for (const line of lines) {
    if (line.length <= LINE_WIDTH) {
      padded.push(line.padEnd(LINE_WIDTH));
    } else {
      for (let offset = 0; offset < line.length; offset += LINE_WIDTH) {
        padded.push(line.slice(offset, offset + LINE_WIDTH).padEnd(LINE_WIDTH));
      }
    }
  }
  return padded.join("\n");
}

/** A BSP page as a text file: the padding off, one newline at the end. */
export function toFile(page) {
  return page.split("\n").map((line) => line.replace(/ +$/, "")).join("\n") + "\n";
}

/**
 * The file name abapGit gives a page: `<bsp>.wapa.<page>`, the page name
 * lower-cased and every "/" written as "_-".
 */
export function pageFileName(prefix, pageName) {
  return prefix + pageName.replace(/\//g, "_-").toLowerCase();
}
