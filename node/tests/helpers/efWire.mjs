// Prints the eF( ) snippet the REAL backend builds for each argument list it
// is given, so a Playwright spec can read them back as JavaScript.
//
// A separate process on purpose: @abaplint/runtime is ESM with internal
// chunk imports, and Playwright's CommonJS transform cannot link them
// ("request for './chunks/root.js' is from a module not been linked"). Node
// loads it natively here, and the spec reads plain JSON back.
//
// stdin : JSON array of argument lists, e.g. [["a"],["first","","third"]]
// stdout: JSON array of the snippets, in the same order
import path from 'path';
import { fileURLToPath } from 'url';

const OUT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..', 'output');

const init = await import(path.join(OUT, 'init.mjs'));
await init.initializeABAP();
const { z2ui5_cl_ui5_srv_event } = await import(path.join(OUT, 'z2ui5_cl_ui5_srv_event.clas.mjs'));
const event = await new z2ui5_cl_ui5_srv_event().constructor_();

const str = (s) => new globalThis.abap.types.String().set(s);
const table = (values) => {
  const t = new globalThis.abap.types.Table(new globalThis.abap.types.String(), {
    withHeader: false, keyType: 'DEFAULT', primaryKey: '', isUnique: false, keyFields: [],
  });
  for (const v of values) globalThis.abap.statements.insertInternal({ data: str(v), table: t });
  return t;
};

const chunks = [];
for await (const chunk of process.stdin) chunks.push(chunk);
const lists = JSON.parse(Buffer.concat(chunks).toString('utf8'));

const out = [];
for (const args of lists) {
  out.push((await event.get_event_client({ val: str('TEST_EVENT'), t_arg: table(args) })).get());
}
process.stdout.write(JSON.stringify(out));
