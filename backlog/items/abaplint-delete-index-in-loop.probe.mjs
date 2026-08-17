/*
 * Detector for `abaplint-delete-index-in-loop`.
 *
 * Walks each file keeping a stack of open `LOOP AT <table>` blocks, and reports
 * a `DELETE <table> INDEX sy-tabix` whose table is one of them. The negative
 * half is the same statement where a `READ TABLE` on that table set `sy-tabix`
 * in the statements just before — the shape the rule must leave alone.
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe =
  'DELETE <t> INDEX sy-tabix inside an open LOOP AT <t>, and the correct READ-TABLE-then-DELETE form as the negative';

const LOOP = /^\s*loop\s+at\s+([a-z_<>0-9-]+)/i;
const ENDLOOP = /^\s*endloop\b/i;
const DELETE = /^\s*delete\s+([a-z_<>0-9-]+)\s+index\s+sy-tabix\s*\./i;
const READ = /^\s*read\s+table\s+([a-z_<>0-9-]+)/i;

// `LOOP AT t ASSIGNING <fs>` and `LOOP AT t INTO x` both name the table first,
// and a field symbol keeps its brackets — strip nothing, compare as written
const norm = (s) => s.toLowerCase().replace(/\[\]$/, '');

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const src = lines(file);
      const open = [];
      // the table a READ TABLE last set sy-tabix for, and how many STATEMENTS
      // ago. Counting statements rather than lines matters: ajson's canonical
      // read-then-delete has a four-line READ TABLE and an IF/RETURN/ENDIF
      // between the two, and a line-counting window missed it entirely - which
      // reported the correct form as absent from a corpus that contains it.
      let lastRead = null;
      let sinceRead = 99;
      src.forEach((line, i) => {
        if (isComment(line) || !line.trim()) return;
        const loop = LOOP.exec(line);
        if (loop) open.push(norm(loop[1]));
        else if (ENDLOOP.test(line)) open.pop();

        const read = READ.exec(line);
        if (read) { lastRead = norm(read[1]); sinceRead = 0; }
        // sy-tabix is set by the loop cursor and by a read; entering either
        // ends the previous read's claim on it
        else if (loop || /^\s*(do|while)\b/i.test(line)) { lastRead = null; }
        // one statement ends at the terminating period
        else if (/\.\s*(?:"[^"]*)?$/.test(line)) sinceRead += 1;

        const del = DELETE.exec(line);
        if (!del) return;
        const t = norm(del[1]);
        const where = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim().slice(0, 60) };
        // read-then-delete is correct: sy-tabix is the index the read just set
        if (lastRead === t && sinceRead <= 8) negatives.push(where);
        else if (open.includes(t)) sites.push(where);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'The detector reads line by line, so a `LOOP AT` or `DELETE` split across '
      + 'lines is missed. A real rule works on the statement tree and would find '
      + 'those too — this is a floor, not a ceiling.',
      '"Within 8 statements of a READ TABLE on the same table" stands in for the '
      + 'rule\'s real condition, which is whether anything has written sy-tabix '
      + 'since. abaplint can ask that exactly; this cannot.',
      'The site count is what is LEFT: seven of the eight found on 2026-08-17 '
      + 'were fixed the same day, so the number here measures the current trees '
      + 'rather than the size of the original finding. The one remaining is '
      + 'vendored upstream code, deliberately not patched downstream.',
    ],
  };
}
