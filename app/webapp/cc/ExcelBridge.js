// Bridge between an abap2UI5 app and the Excel workbook it runs next to,
// for an app shown in the task pane of an Excel add-in. Office.js
// (window.Office, window.Excel) is loaded by the add-in's host page - this
// control never loads it and only uses it when it is there: in the same
// window, after Office.onReady( ), with Office.context.host Excel. In a plain
// browser it is an invisible placeholder that does nothing until an app
// calls write( ) or read( ), which then fire OnError - the same view runs
// unchanged in both places.
//
// The control decides nothing (AGENTS.md rule 10). It writes what its
// bindings hold and reads the user's selection into a binding:
//   write( ) - `rows` (an ABAP table, bound with _bind) goes to the sheet:
//              `columns` picks and orders the fields (a comma-separated
//              string, an array of names, or an array of objects with
//              KEY / HEADER / NUMBER_FORMAT), `target` says where (a cell
//              address like B3, `selection` or `newSheet`, with `sheetName`
//              for the sheet), `asTable` makes it an Excel table with a
//              header row, `numberFormats` (an array along the columns or
//              an object by column key) formats numbers and dates. Then
//              OnWritten with the address, or OnError.
//   read( )  - the selected range lands in `selection` as rows of
//              { COL1, COL2, ... } - an ABAP table of a structure with
//              components col1, col2, ... takes it, a component the
//              structure leaves out is skipped - and its address in
//              `selectionAddress`; then OnRead, or OnError.
// An app calls both as a frontend action on the control's id, from a button
// in the view (roundtrip-free) or after a roundtrip:
//   client->follow_up_action( val   = client->cs_event-control_by_id
//                             t_arg = VALUE #( ( `excel` ) ( `write` ) ) ).
// `selectionChange` (off by default) fires OnSelectionChange with the new
// address whenever the user selects something else. `available` turns true
// once Excel answered, so a view can bind its Excel buttons' visible to it.
//
// What goes over the bridge is bounded: more than `maxCells` cells (header
// included, at most HARD_MAX_CELLS) is refused with OnError, nothing
// written and nothing read - Excel on the web takes a few MB per request.
// Values keep their types: a number stays a number, a string is written as
// TEXT (the cell gets the number format @), so a material number keeps its
// leading zeros and a string starting with = is never a formula. An ISO
// date or timestamp - how abap2UI5 sends an ABAP d or timestamp - becomes an
// Excel date. A read hands numbers back as numbers, and a date cell as the
// ISO text an ABAP d takes.
//
// Hosting: Office.js only works in the top document of the task pane, and
// this control looks for it in its own window - so that document has to
// run abap2UI5 itself and load Office.js: a host page of the add-in that
// embeds the component (?z2ui5-bundle, abap2UI5/embed-control) or a page
// of the system that loads it. What the add-in provides is described in
// abap2UI5/office-addin.
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/Env"],
  (Control, Lib, Env) => {
    "use strict";

    const DEFAULT_MAX_CELLS = 20000;
    const HARD_MAX_CELLS = 100000;
    const SELECTION_DEBOUNCE_MS = 300;
    // 1899-12-30: day 0 of the Excel date system (1900, with its leap-day
    // quirk absorbed for every date from March 1900 on)
    const EXCEL_EPOCH_MS = Date.UTC(1899, 11, 30);
    const DAY_MS = 86400000;
    // anchored at BOTH ends: the whole string is a date, a timestamp, or a
    // timestamp with fraction, Z or offset. Open at the end, any text that
    // merely BEGINS with a date ("2024-01-15 delivery", a document number
    // "2024-01-15-0001") was written as that date and the rest was lost
    const ISO_DATE =
      /^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?)?$/;
    // a single cell, optionally $-anchored: A1, $B$3, XFD1048576
    const CELL_ADDRESS = /^\$?[A-Za-z]{1,3}\$?[1-9][0-9]{0,6}$/;

    // The Excel namespace when this page runs inside Excel, else undefined.
    // Asked once per page when Office.js is there - Office.onReady( )
    // settles once. Without it nothing is kept, so a host page that loads
    // Office.js after the frontend booted is still found on the next call.
    let excelReady;
    function excel() {
      if (excelReady) return excelReady;
      const w = /** @type {any} */ (window);
      const Office = w.Office;
      if (!Office || typeof Office.onReady !== "function") {
        return Promise.resolve(undefined);
      }
      excelReady = Promise.resolve()
        .then(() => Office.onReady())
        .then(
          (info) => {
            const host = info?.host ?? Office.context?.host;
            const isExcel = host != null && host === Office.HostType?.Excel;
            return isExcel && typeof w.Excel?.run === "function"
              ? w.Excel
              : undefined;
          },
          () => undefined,
        );
      return excelReady;
    }

    // Case-insensitive member of a plain object - ABAP sends KEY, an app
    // writing JSON by hand may send key.
    function member(obj, names) {
      if (!obj || typeof obj !== "object") return undefined;
      for (const name of names) {
        if (obj[name] !== undefined) return obj[name];
        const hit = Object.keys(obj).find(
          (k) => k.toLowerCase() === name.toLowerCase(),
        );
        if (hit !== undefined) return obj[hit];
      }
      return undefined;
    }

    // `columns` in any of its spellings -> [{ key, header, format }].
    function normalizeColumns(columns, firstRow) {
      let list = columns;
      if (typeof list === "string") {
        list = list
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);
      }
      if (!Array.isArray(list) || !list.length) {
        if (Array.isArray(firstRow)) {
          return firstRow.map((_v, i) => ({
            key: i,
            header: `COL${i + 1}`,
            format: "",
          }));
        }
        return firstRow && typeof firstRow === "object"
          ? Object.keys(firstRow).map((k) => ({
              key: k,
              header: k,
              format: "",
            }))
          : [];
      }
      return list.map((c) => {
        if (c && typeof c === "object") {
          const key = Lib.toText(member(c, ["key", "name", "field"]));
          const header = member(c, ["header", "text", "label"]);
          return {
            key,
            // an ABAP column row with HEADER left empty is labelled by its key
            header: Lib.toText(header) || key,
            format: Lib.toText(member(c, ["number_format", "numberFormat"])),
          };
        }
        const key = Lib.toText(c);
        return { key, header: key, format: "" };
      });
    }

    // The key a row really carries for a column (MATNR for matnr).
    function resolveKey(row, key) {
      if (!row || typeof row !== "object" || Array.isArray(row)) return key;
      if (key in row) return key;
      const hit = Object.keys(row).find(
        (k) => k.toLowerCase() === String(key).toLowerCase(),
      );
      return hit === undefined ? key : hit;
    }

    function isoToSerial(text) {
      const m = ISO_DATE.exec(text);
      if (!m) return undefined;
      const [, y, mo, d, h = "0", mi = "0", s = "0"] = m;
      if (Number(y) < 1900) return undefined;
      const ms = Date.UTC(+y, +mo - 1, +d, +h, +mi, +s);
      // Date.UTC rolls 2024-02-31 over into March - not a date then
      if (new Date(ms).getUTCDate() !== +d) return undefined;
      return {
        serial: (ms - EXCEL_EPOCH_MS) / DAY_MS,
        hasTime: m[4] !== undefined,
      };
    }

    // One value as Excel takes it, with the number format it needs.
    function toCell(value, format) {
      if (typeof value === "number") {
        return Number.isFinite(value)
          ? { value, format: format || "General" }
          : { value: "", format: "@" };
      }
      if (typeof value === "boolean") return { value, format: "General" };
      if (value == null || typeof value === "object") {
        return { value: "", format: "@" };
      }
      const text = String(value);
      const date = isoToSerial(text);
      if (date && text.length <= 25) {
        const own = date.hasTime ? "yyyy-mm-dd hh:mm:ss" : "yyyy-mm-dd";
        return { value: date.serial, format: format || own };
      }
      return { value: text, format: "@" };
    }

    // `rows` + `columns` + `numberFormats` -> the values and number formats
    // of the range, header row first. Pure, so the spec can hold it.
    function buildMatrix({ rows, columns, numberFormats, header }) {
      const list = Array.isArray(rows) ? rows : [];
      const cols = normalizeColumns(columns, list[0]);
      if (!cols.length) return { values: [], formats: [], columns: 0 };
      const keys = cols.map((c) => resolveKey(list[0], c.key));
      const formats = cols.map((c, i) => {
        if (c.format) return c.format;
        if (Array.isArray(numberFormats)) {
          return Lib.toText(numberFormats[i]);
        }
        return Lib.toText(member(numberFormats, [String(c.key)]));
      });
      const values = [];
      const cellFormats = [];
      if (header) {
        values.push(cols.map((c) => c.header));
        cellFormats.push(cols.map(() => "@"));
      }
      for (const row of list) {
        const valueRow = [];
        const formatRow = [];
        keys.forEach((key, i) => {
          const cell = toCell(row?.[key], formats[i]);
          valueRow.push(cell.value);
          formatRow.push(cell.format);
        });
        values.push(valueRow);
        cellFormats.push(formatRow);
      }
      return { values, formats: cellFormats, columns: cols.length };
    }

    // A number format that shows a date or a time - after the quoted text,
    // the escaped characters and the [Red] / [$-409] sections are cut out.
    function isDateFormat(format) {
      const bare = String(format ?? "")
        .replace(/"[^"]*"/g, "")
        .replace(/\\./g, "")
        .replace(/\[[^\]]*\]/g, "");
      return /[dy]/i.test(bare) || /h/i.test(bare);
    }

    function serialToIso(serial, format) {
      const ms = Math.round(serial * DAY_MS) + EXCEL_EPOCH_MS;
      const iso = new Date(ms).toISOString();
      const bare = String(format).replace(/"[^"]*"/g, "");
      const hasDate = /[dy]/i.test(bare);
      const hasTime = /h/i.test(bare);
      if (hasDate && hasTime) return iso.slice(0, 19);
      if (hasTime) return iso.slice(11, 19);
      return iso.slice(0, 10);
    }

    // The values of a read range -> [{ COL1, COL2, ... }].
    function toRows(values, formats) {
      return (values || []).map((row, r) => {
        const out = {};
        row.forEach((v, c) => {
          const format = formats?.[r]?.[c];
          let value = v;
          if (typeof v === "number" && format && isDateFormat(format)) {
            value = serialToIso(v, format);
          }
          out[`COL${c + 1}`] = value;
        });
        return out;
      });
    }

    function failure(e, fallback) {
      return {
        message: Lib.toText(e?.message ?? e) || fallback,
        code: Lib.toText(e?.code),
      };
    }

    const definition = {
      metadata: {
        // a literal here, not a constant: the linter mirrors it from this
        // source (check-upstream reads the metadata object literal)
        properties: {
          rows: { type: "any", defaultValue: null },
          columns: { type: "any", defaultValue: null },
          numberFormats: { type: "any", defaultValue: null },
          target: { type: "string", defaultValue: "A1" },
          sheetName: { type: "string", defaultValue: "" },
          asTable: { type: "boolean", defaultValue: true },
          header: { type: "boolean", defaultValue: true },
          maxCells: { type: "int", defaultValue: 20000 },
          selection: { type: "any", defaultValue: null },
          selectionAddress: { type: "string", defaultValue: "" },
          readText: { type: "boolean", defaultValue: false },
          selectionChange: { type: "boolean", defaultValue: false },
          available: { type: "boolean", defaultValue: false },
        },
        events: {
          OnWritten: {
            parameters: {
              address: { type: "string" },
              rowCount: { type: "int" },
              columnCount: { type: "int" },
            },
          },
          OnRead: {
            parameters: {
              address: { type: "string" },
              rowCount: { type: "int" },
              columnCount: { type: "int" },
            },
          },
          OnSelectionChange: {
            parameters: {
              address: { type: "string" },
            },
          },
          OnError: {
            parameters: {
              message: { type: "string" },
              code: { type: "string" },
            },
          },
        },
      },

      init() {
        // one operation at a time, in the order the app asked for them
        this._queue = Promise.resolve();
        this._probed = false;
        this._subscription = null;
        this._subscribing = false;
        this._selectionTimer = null;
        this._lastAddress = "";
      },

      exit() {
        clearTimeout(this._selectionTimer);
        this._unsubscribe();
      },

      setSelectionChange(val) {
        this.setProperty("selectionChange", val, true);
        this._syncSubscription();
        return this;
      },

      onAfterRendering() {
        if (!this._probed) this._probe();
        this._syncSubscription();
      },

      // Latched only once Office.js is on the page - its answer is final
      // then. Before that every rendering asks again: excel( ) keeps nothing
      // while Office.js is missing precisely so a host page that loads it
      // late is still found, and a latch set on the first rendering meant
      // `available` stayed false for the life of the control.
      _probe() {
        const w = /** @type {any} */ (window);
        if (!w.Office) return;
        this._probed = true;
        excel().then((Excel) => {
          if (!Excel || Lib.isDestroyed(this)) return;
          if (!this.getProperty("available")) {
            this.setProperty("available", true, true);
          }
        });
      },

      _fail(message, code) {
        if (Lib.isDestroyed(this)) return;
        this.fireOnError({ message, code: code || "" });
      },

      _limit() {
        const max = Number(this.getProperty("maxCells")) || DEFAULT_MAX_CELLS;
        return Math.min(Math.max(1, max), HARD_MAX_CELLS);
      },

      // Runs `op(Excel)` after the operations queued before it; outside
      // Excel it fires OnError instead. Returns the promise, so a caller
      // (the spec) can wait - the frontend action does not.
      _enqueue(name, op) {
        const run = () =>
          excel().then((Excel) => {
            if (Lib.isDestroyed(this)) return undefined;
            if (!Excel) {
              this._fail("Excel not available", "NotAvailable");
              return undefined;
            }
            return Promise.resolve()
              .then(() => op(Excel))
              .catch((e) => {
                const f = failure(e, `${name} failed`);
                Lib.logError(`ExcelBridge: ${name} - ${f.message}`, e);
                this._fail(f.message, f.code);
              });
          });
        this._queue = this._queue.then(run, run);
        return this._queue;
      },

      write() {
        // the bindings as they stand NOW - a later change does not leak
        // into a write that is still waiting for its turn
        const asTable = Boolean(this.getProperty("asTable"));
        const matrix = buildMatrix({
          rows: this.getProperty("rows"),
          columns: this.getProperty("columns"),
          numberFormats: this.getProperty("numberFormats"),
          header: asTable || Boolean(this.getProperty("header")),
        });
        const target = Lib.toText(this.getProperty("target")).trim() || "A1";
        const sheetName = Lib.toText(this.getProperty("sheetName")).trim();
        const limit = this._limit();
        return this._enqueue("write", (Excel) => {
          const rowCount = matrix.values.length;
          const columnCount = matrix.columns;
          if (!rowCount || !columnCount) {
            this._fail("nothing to write", "NoData");
            return Promise.resolve();
          }
          if (rowCount * columnCount > limit) {
            this._fail(
              `${rowCount * columnCount} cells exceed the limit of ${limit}`,
              "TooLarge",
            );
            return Promise.resolve();
          }
          const mode = target.toLowerCase();
          if (
            mode !== "selection" &&
            mode !== "newsheet" &&
            !CELL_ADDRESS.test(target)
          ) {
            this._fail(`invalid target '${target}'`, "InvalidTarget");
            return Promise.resolve();
          }
          return Excel.run(async (context) => {
            const book = context.workbook;
            let anchor;
            let sheet;
            if (mode === "selection") {
              anchor = book.getSelectedRange().getCell(0, 0);
              sheet = anchor.worksheet;
            } else if (mode === "newsheet") {
              sheet = book.worksheets.add(sheetName || undefined);
              sheet.activate();
              anchor = sheet.getRange("A1");
            } else {
              sheet = sheetName
                ? book.worksheets.getItem(sheetName)
                : book.worksheets.getActiveWorksheet();
              anchor = sheet.getRange(target);
            }
            const range = anchor.getResizedRange(rowCount - 1, columnCount - 1);
            // the formats first: a cell formatted @ takes the value as text
            range.numberFormat = matrix.formats;
            range.values = matrix.values;
            if (asTable) sheet.tables.add(range, true);
            range.format.autofitColumns();
            range.load("address");
            await context.sync();
            if (Lib.isDestroyed(this)) return;
            this.fireOnWritten({
              address: Lib.toText(range.address),
              rowCount,
              columnCount,
            });
          });
        });
      },

      read() {
        const readText = Boolean(this.getProperty("readText"));
        const limit = this._limit();
        return this._enqueue("read", (Excel) =>
          Excel.run(async (context) => {
            let range = context.workbook.getSelectedRange();
            range.load("address,rowCount,columnCount");
            await context.sync();
            // a whole column selected is a million cells, of which the
            // used part is what the user meant
            if (range.rowCount * range.columnCount > limit) {
              range = range.getUsedRangeOrNullObject(true);
              range.load("address,rowCount,columnCount,isNullObject");
              await context.sync();
            }
            if (range.isNullObject) {
              this._deliver([], "", 0, 0);
              return;
            }
            const cells = range.rowCount * range.columnCount;
            if (cells > limit) {
              this._fail(
                `${cells} cells exceed the limit of ${limit}`,
                "TooLarge",
              );
              return;
            }
            range.load(readText ? "text" : "values,numberFormat");
            await context.sync();
            const rows = readText
              ? toRows(range.text, null)
              : toRows(range.values, range.numberFormat);
            this._deliver(
              rows,
              Lib.toText(range.address),
              range.rowCount,
              range.columnCount,
            );
          }),
        );
      },

      _deliver(rows, address, rowCount, columnCount) {
        if (Lib.isDestroyed(this)) return;
        this.setProperty("selection", rows, true);
        this.setProperty("selectionAddress", address, true);
        this.fireOnRead({ address, rowCount, columnCount });
      },

      // Subscribed exactly while selectionChange is on and the control
      // lives - called from the setter and after every render.
      _syncSubscription() {
        const wanted =
          Boolean(this.getProperty("selectionChange")) &&
          !Lib.isDestroyed(this);
        if (wanted && !this._subscription && !this._subscribing) {
          this._subscribe();
        } else if (!wanted && this._subscription) {
          this._unsubscribe();
        }
      },

      _subscribe() {
        this._subscribing = true;
        excel()
          .then((Excel) => {
            if (!Excel) return undefined;
            return Excel.run(async (context) => {
              const handler = context.workbook.onSelectionChanged.add(() =>
                this._selectionChanged(Excel),
              );
              await context.sync();
              return handler;
            });
          })
          .then(
            (handler) => {
              this._subscribing = false;
              if (!handler) return;
              this._subscription = handler;
              // switched off or destroyed while subscribing
              this._syncSubscription();
            },
            (e) => {
              this._subscribing = false;
              Lib.logError("ExcelBridge: selection subscription failed", e);
            },
          );
      },

      _unsubscribe() {
        const handler = this._subscription;
        if (!handler) return;
        this._subscription = null;
        const Excel = /** @type {any} */ (window).Excel;
        if (typeof Excel?.run !== "function" || !handler.context) return;
        Excel.run(handler.context, async (context) => {
          handler.remove();
          await context.sync();
        }).catch((e) =>
          Lib.logError("ExcelBridge: selection unsubscribe failed", e),
        );
      },

      // A drag over the sheet is a burst of changes: only where it ends is
      // reported, and only when it is a new address.
      _selectionChanged(Excel) {
        clearTimeout(this._selectionTimer);
        this._selectionTimer = setTimeout(() => {
          if (Lib.isDestroyed(this) || !this._subscription) return;
          Excel.run(async (context) => {
            const range = context.workbook.getSelectedRange();
            range.load("address");
            await context.sync();
            const address = Lib.toText(range.address);
            if (Lib.isDestroyed(this) || address === this._lastAddress) return;
            this._lastAddress = address;
            this.fireOnSelectionChange({ address });
          }).catch((e) =>
            Lib.logError("ExcelBridge: reading the selection failed", e),
          );
        }, SELECTION_DEBOUNCE_MS);
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          Lib.renderInvisibleSpan(oRm, oControl);
        },
      },
    };

    // The renderer draws none of the properties: every setter writes
    // without invalidating (AGENTS.md rule 10). selectionChange keeps its
    // own setter, which applies its effect on top.
    for (const name of Object.keys(definition.metadata.properties)) {
      const setter = `set${name[0].toUpperCase()}${name.slice(1)}`;
      if (definition[setter]) continue;
      definition[setter] = function (val) {
        this.setProperty(name, val, true);
        return this;
      };
    }

    const ExcelBridge = Control.extend("z2ui5.cc.ExcelBridge", definition);

    // the pure helpers, for the spec
    ExcelBridge._buildMatrix = buildMatrix;
    ExcelBridge._toRows = toRows;
    return Env.ownClass(ExcelBridge);
  },
);
