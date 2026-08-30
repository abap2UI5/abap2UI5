// Pre-downport patch: make abaplint's table-expression outline keep the ROW
// reference instead of copying it into a work area.
//
// Runs against the INSTALLED @abaplint/cli bundle in this checkout, before
// `abaplint --fix` reads it. It is a temporary shim for a defect filed
// upstream as `backlog/items/abaplint-downport-table-expression-copy.md`
// (abaplint/abaplint); the patch it applies is the one that item carries, and
// it goes away the moment abaplint ships the fix - see "Removing this" below.
//
// Why:
//
// From 7.40 a table expression in a read position ADDRESSES the row - it is
// not a copy, which is why `tab[ i ]-comp = x` is legal and `REF #( tab[ i ] )`
// hands back a reference into the table. abaplint's downport outlines the
// COMPONENT-level read into a work area:
//
//     lr = REF #( mt_tab[ 1 ]-name ).
//   ->
//     DATA temp1 LIKE LINE OF mt_tab.
//     READ TABLE mt_tab INDEX 1 INTO temp1.      " <- a COPY
//     ASSIGN temp1-name TO <temp2>.
//     GET REFERENCE OF <temp2> INTO lr.
//
// For a value read the two are indistinguishable. For anything that takes the
// value's ADDRESS they are not - a pass-by-reference actual parameter,
// `REF #( )`, `ASSIGN`. The rule already knows this: its WRITE path
// (`moveWithTableTarget`) emits `READ TABLE ... ASSIGNING`, which is why
// `tab[ i ] = x`, `REF #( tab[ i ] )` and `ASSIGN tab[ i ] TO <row>` survive
// the downport and only the component-level read does not.
//
// What it costs us without the patch: `client->_bind( tab / tab_index )` - the
// cell binding - identifies the bound cell by data reference, so the natural
// spelling
//
//     client->_bind( val = t_employees[ 1 ]-name tab = t_employees tab_index = 1 )
//
// is refused with BINDING_ERROR_TAB_CELL_LEVEL in every downported build: the
// 702 branch, the transpiled Node backend behind the browser tests here, and
// the sample corpora's e2e smoke. The workaround an app would otherwise have
// to write - assign the row to a field symbol first and bind `<row>-name` -
// costs one field symbol and one ASSIGN per row, which for the six-employee
// UxAP ports is the whole gain of using a table in the first place.
//
// Two edits, both taken verbatim from the upstream patch:
//
//   1. `replaceTableExpression` emits the FIELD-SYMBOLS / ASSIGNING shape its
//      sibling already uses.
//   2. `uniqueName` learns the field-symbol spelling. A `FIELD-SYMBOLS <temp3>`
//      declaration is known to the scope as "<temp3>", so looking up the bare
//      "temp3" reports it free and a SECOND outline in the same method is
//      handed the same name - the result then does not compile
//      ("Variable name <temp3> already defined"). Found by running edit 1
//      alone against a class with two outlines in one method.
//
// Verified with the change in abaplint's own tree: `packages/core` green,
// 10885 passing, four `testFix` expectations updated to the new output (they
// are fixture text, not assertions about semantics).
//
// Removing this: when abaplint ships the fix, the anchors below stop matching
// and this script FAILS the build rather than passing silently. That is
// deliberate - it is the signal to delete the script, its call sites and the
// backlog item. The canary that proves the shim still WORKS is
// `test_bind_tab_cell` in z2ui5_cl_ui5_client's test class: it writes the
// natural spelling and is only green because of this patch.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

const BUNDLE = new URL('../../node_modules/@abaplint/cli/build/cli.js', import.meta.url);

/* 1. the outline itself. Anchor and patch are whole statements including the
 *    template literal, so a reformat upstream misses rather than half-applies. */
const OUTLINE_ANCHOR = `            const uniqueName = this.uniqueName(high.getFirstToken().getStart(), lowFile.getFilename(), highSyntax);
            const tabixBackup = this.uniqueName(high.getFirstToken().getStart(), lowFile.getFilename(), highSyntax);
            const indentation = " ".repeat(high.getFirstToken().getStart().getCol() - 1);
            const firstToken = high.getFirstToken();
            // note that the tabix restore should be done before throwing the exception
            const fix1 = edit_helper_1.EditHelper.insertAt(lowFile, firstToken.getStart(), \`DATA \${uniqueName} LIKE LINE OF \${pre}.
\${indentation}DATA \${tabixBackup} LIKE sy-tabix.
\${indentation}\${tabixBackup} = sy-tabix.
\${indentation}READ TABLE \${pre} \${condition}INTO \${uniqueName}.`;

const OUTLINE_PATCH = `            const uniqueName = this.uniqueName(high.getFirstToken().getStart(), lowFile.getFilename(), highSyntax, true);
            const tabixBackup = this.uniqueName(high.getFirstToken().getStart(), lowFile.getFilename(), highSyntax);
            const indentation = " ".repeat(high.getFirstToken().getStart().getCol() - 1);
            const firstToken = high.getFirstToken();
            // note that the tabix restore should be done before throwing the exception
            const fix1 = edit_helper_1.EditHelper.insertAt(lowFile, firstToken.getStart(), \`FIELD-SYMBOLS \${uniqueName} LIKE LINE OF \${pre}.
\${indentation}DATA \${tabixBackup} LIKE sy-tabix.
\${indentation}\${tabixBackup} = sy-tabix.
\${indentation}READ TABLE \${pre} \${condition}ASSIGNING \${uniqueName}.`;

/* 2. the name generator. Only the outline above passes the new flag, so every
 *    other caller keeps the plain spelling it has today. */
const NAME_ANCHOR = `    uniqueName(position, filename, highSyntax) {
        const spag = highSyntax.spaghetti.lookupPosition(position, filename);
        if (spag === undefined) {
            const name = "temprr" + this.counter;
            this.counter++;
            return name;
        }`;

const NAME_PATCH = `    uniqueName(position, filename, highSyntax, fieldSymbol = false) {
        const decorate = (n) => fieldSymbol ? "<" + n + ">" : n;
        const spag = highSyntax.spaghetti.lookupPosition(position, filename);
        if (spag === undefined) {
            const name = "temprr" + this.counter;
            this.counter++;
            return decorate(name);
        }`;

const LOOP_ANCHOR = `            const name = "temp" + this.counter + postfix;
            const exists = this.existsRecursive(spag, name);`;

const LOOP_PATCH = `            const name = decorate("temp" + this.counter + postfix);
            const exists = this.existsRecursive(spag, name);`;

const EDITS = [
  [OUTLINE_ANCHOR, OUTLINE_PATCH, 'downport replaceTableExpression outline'],
  [NAME_ANCHOR, NAME_PATCH, 'downport uniqueName signature'],
  [LOOP_ANCHOR, LOOP_PATCH, 'downport uniqueName collision check'],
];

export function patchAbaplintDownport(bundle = fileURLToPath(BUNDLE)) {
  if (!existsSync(bundle)) {
    throw new Error(`patch-abaplint-downport: ${bundle} not found - run npm install first`);
  }
  let src = readFileSync(bundle, 'utf8');
  let applied = 0;
  for (const [anchor, patch, note] of EDITS) {
    if (src.includes(patch)) continue; // already patched (re-runnable)
    if (!src.includes(anchor)) {
      throw new Error(
        `patch-abaplint-downport: anchor not found (${note}).\n`
        + '  Either abaplint changed the downport rule, or it SHIPPED the fix.\n'
        + '  Check abaplint/abaplint against backlog/items/abaplint-downport-table-expression-copy.md:\n'
        + '  if the fix is upstream, delete this script, its call in the `downport` npm script,\n'
        + '  the call in samples-controls/scripts/e2e-build.mjs and the backlog item.');
    }
    src = src.replace(anchor, patch);
    applied++;
  }
  if (applied) writeFileSync(bundle, src);
  console.log(`patch-abaplint-downport: ${applied ? `${applied} edit(s) applied` : 'already patched'} - ${bundle}`);
}

// CLI: node node/setup/patch-abaplint-downport.mjs [path-to-cli.js]
if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  patchAbaplintDownport(process.argv[2] || fileURLToPath(BUNDLE));
}
