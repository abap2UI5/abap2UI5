{
// zw3mi.fugr.saplzw3mi.abap


// zw3mi.fugr.wwwdata_export.abap
async function wwwdata_export(INPUT) {
        // importing KEY WWWDATATAB false
        let key = INPUT.exporting?.key;
        // tables MIME W3MIME true
        let mime = INPUT.tables?.mime;
        if (mime === undefined) {
                  mime = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "W3MIME", "W3MIME", {}, {}), {"withHeader":true,"keyType":"DEFAULT"});
              }
              abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
          }
          abap.FunctionModules['WWWDATA_EXPORT'] = wwwdata_export;// zw3mi.fugr.wwwdata_import.abap
          async function wwwdata_import(INPUT) {
                // importing KEY WWWDATATAB false
                let key = INPUT.exporting?.key;
                // tables MIME W3MIME true
                let mime = INPUT.tables?.mime;
                if (mime === undefined) {
                        mime = abap.types.TableFactory.construct(new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "W3MIME", "W3MIME", {}, {}), {"withHeader":true,"keyType":"DEFAULT"});
                    }
                    let filename = new abap.types.String({qualifiedName: "STRING"});
                    let xstr = new abap.types.XString({qualifiedName: "XSTRING"});
                    let row = new abap.types.Structure({"line": new abap.types.Hex({length: 255})}, "W3MIME", "W3MIME", {}, {});
                    let len = new abap.types.Integer({qualifiedName: "I"});
                    abap.statements.clear(mime);
                    filename.set(abap.W3MI[key.get().objid.get().trimEnd()].filename);
                    const fs = await import("fs");
                    const path = await import("path");
                    const url = await import("url");
                    const __filename = url.fileURLToPath(import.meta.url);
                    const __dirname = path.dirname(__filename);
                    xstr.set(fs.readFileSync(__dirname + path.sep + filename.get()).toString("hex").toUpperCase());
                    const indexBackup1 = abap.builtin.sy.get().index.get();
                    let unique189 = 1;
                    while (abap.compare.gt(abap.builtin.xstrlen({val: xstr}), abap.IntegerFactory.get(0))) {
                          abap.builtin.sy.get().index.set(unique189++);
                          len.set(new abap.types.Integer().set(255));
                          if (abap.compare.lt(abap.builtin.xstrlen({val: xstr}), len)) {
                                len.set(abap.builtin.xstrlen({val: xstr}));
                              }
                              row.get().line.set(xstr.getOffset({length: len}));
                              abap.statements.append({source: row, target: mime});
                              xstr.set(xstr.getOffset({offset: len}));
                            }
                            abap.builtin.sy.get().index.set(indexBackup1);
                            abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
                          }
                          abap.FunctionModules['WWWDATA_IMPORT'] = wwwdata_import;// zw3mi.fugr.wwwparams_insert.abap
                        async function wwwparams_insert(INPUT) {
                            // importing PARAMS WWWPARAMS false
                            let params = INPUT.exporting?.params;
                            abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
                          }
                          abap.FunctionModules['WWWPARAMS_INSERT'] = wwwparams_insert;// zw3mi.fugr.wwwparams_read.abap
              async function wwwparams_read(INPUT) {
                // importing RELID WWWPARAMS-RELID false
                let relid = INPUT.exporting?.relid;
                // importing OBJID WWWPARAMS-OBJID false
                let objid = INPUT.exporting?.objid;
                // importing NAME C false
                let name = INPUT.exporting?.name;
                // exporting VALUE C true
                let value = INPUT.importing?.value;
                if (value === undefined) {
                    value = new abap.types.Character(1, {});
                }
                let filename = new abap.types.String({qualifiedName: "STRING"});
                let filesize = new abap.types.Integer({qualifiedName: "I"});
                filename.set(abap.W3MI[objid.get().trimEnd()].filename);
                const fs = await import("fs");
                const path = await import("path");
                const url = await import("url");
                const __filename = url.fileURLToPath(import.meta.url);
                const __dirname = path.dirname(__filename);
                const buf = fs.readFileSync(__dirname + path.sep + filename.get());
                if (abap.compare.eq(name, new abap.types.Character(8).set('filesize'))) {
                  filesize.set(buf.length);
                  value.set(filesize);
                  abap.statements.condense(value, {nogaps: false});
                } else {
                  abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
                }
                abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
              }
              abap.FunctionModules['WWWPARAMS_READ'] = wwwparams_read;
}
//# sourceMappingURL=zw3mi.fugr.mjs.map