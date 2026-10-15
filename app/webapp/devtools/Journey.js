// The journey recorder of the developer tools - a click-through in the
// browser becomes an ABAP Unit test.
//
// The developer presses "Record Journey", uses the app, presses it again,
// and "Export ABAP Unit" hands over a local test class that replays the
// same steps on z2ui5_cl_frontend_simulator - the headless frontend of
// abap2UI5/headless-frontend, which speaks this frontend's wire protocol
// from inside an ABAP Unit test: set_value( ) for what the user typed,
// click( ) for the event, and assertions on what the screen showed
// afterwards. The test is pasted into the app's test include; it needs no
// browser, no HTTP and no deployed frontend to run.
//
// Every step is ONE roundtrip, read off the request and the response the
// way the recorder of the history does: the request carries the event
// (S_FRONT.EVENT), its arguments (T_EVENT_ARG) and the model delta
// (MODEL) - exactly what the user changed on the screen before the
// event, which is exactly what the simulator's setters take; the response
// carries the views it displayed, the messages it showed and the app that
// answered, which is what the generated test asserts on. Nothing else is
// needed, so nothing else is stored: the view XML of a step is reduced to
// the control ids and the event names in it the moment it arrives.
//
// SELF-CONTAINED, like devtools/Recorder.js: the framework carries no
// journey code. The hook is the public onAfterRendering callback array
// of the component context (Lib.registerCallback), registered only while
// a recording runs, the two response readers are the recorder's and the
// running class is what devtools/AbapSource.js reports. The
// whole feature goes with this file, its tab entry in devtools/Tabs.js
// and its buttons in the dialog.
//
// PER COMPONENT CONTEXT (core/Context.js): a journey belongs to the
// component that was clicked through, so the record is
// `ctx.devtools.journey` and every function takes the context first.
//
// The limits of a recording, written into the exported class as well:
//   - the test STARTS the app fresh. A recording that began in the middle
//     of a session replays its steps against a fresh start, which may not
//     reach the same screens - record from the app start for a faithful
//     replay
//   - a roundtrip without an event (the start, a reload, a Back/Forward
//     restore) is not replayed; its screen is asserted when it is the
//     first step
//   - what never reaches the backend is not recorded: a popup closed in
//     the browser alone (_event_client), a frontend action, a timer
//   - the simulator sends an edit to the topmost open layer, the browser
//     to the layer the control sits in - the same layer in every ordinary
//     flow, but not for a value typed into the page behind an open popup
sap.ui.define(
  ["z2ui5/core/Lib", "z2ui5/devtools/AbapSource", "z2ui5/devtools/Recorder"],
  (Lib, AbapSource, Recorder) => {
    "use strict";

    // Steps kept per journey. A test with more steps than this is not a
    // test anybody reads; the recording stops taking steps and says so.
    const MAX_STEPS = 200;

    // How many ids, and how many events when a view carries no ids, the
    // exported class asserts per step. Enough to tell the screens apart,
    // few enough that a renamed button does not fail every method.
    const MAX_ASSERT_IDS = 5;
    const MAX_ASSERT_EVENTS = 5;

    // A model delta larger than this (serialized) is not kept - a whole
    // table pasted into a test is not a test. The step records that it
    // was dropped, and the export says so where the setters would be.
    const MAX_DELTA_CHARS = 20000;

    // An ABAP line is at most 255 characters; a literal longer than this
    // is split into concatenated chunks, one per line.
    const LITERAL_CHUNK = 100;

    // The slots a response can display, topmost first - the order the
    // simulator's layer_top( ) uses, so the generated assertions name the
    // layer the simulator will report.
    const SLOT_ORDER = ["POPOVER", "POPUP", "MAIN"];

    // The per-context record, `ctx.devtools.journey`:
    //   recording   true while the hook is registered
    //   journeys    every recording since the last Clear, oldest first:
    //               { app, startedAt, steps, overflow }
    //   hook        the onAfterRendering callback while recording, else null
    function journeyOf(ctx) {
      return ctx?.devtools?.journey || null;
    }

    function ensure(ctx) {
      if (!ctx?.devtools) return null;
      if (!ctx.devtools.journey) {
        ctx.devtools.journey = { recording: false, journeys: [], hook: null };
      }
      return ctx.devtools.journey;
    }

    function current(rec) {
      return rec?.journeys[rec.journeys.length - 1] || null;
    }

    function isRecording(ctx) {
      return Boolean(journeyOf(ctx)?.recording);
    }

    // The app class that answered the last response - what the exported
    // test starts. devtools/AbapSource.js is the one module that knows the
    // running class (the ABAP Source tab and the ADT jump read it there).
    function appOf(ctx) {
      return AbapSource.appName(ctx);
    }

    // ------------------------------------------------------------------
    // Reading one roundtrip
    // ------------------------------------------------------------------

    // The ids the app wrote into a view - id="..." attributes, read off the
    // XML text the way the simulator's get_ids( ) reads them (a blank, the
    // name, the quote - which keeps width="..." out). The backend
    // generates no ids, so what is found is what the app named.
    function idsOf(xml) {
      const out = [];
      const pattern = / id="([^"]*)"/g;
      let match = pattern.exec(xml || "");
      while (match !== null) {
        const id = match[1].replace(/&amp;/g, "&");
        if (id && !out.includes(id)) out.push(id);
        match = pattern.exec(xml);
      }
      return out;
    }

    // The events wired in a view: the .eB(['NAME', ...]) and
    // .eBP($event, cond, ['NAME', ...]) wires z2ui5_cl_ui5_srv_event
    // writes, the name a single-quoted JS literal (XML-escaped on top).
    function eventsOf(xml) {
      const text = (xml || "")
        .replace(/&apos;/g, "'")
        .replace(/&quot;/g, '"')
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&amp;/g, "&");
      const out = [];
      const pattern = /\.eBP?\((?:[^[]*?)\['((?:\\.|[^'\\])*)'/g;
      let match = pattern.exec(text);
      while (match !== null) {
        const name = match[1].replace(/\\(.)/g, "$1");
        if (name && !out.includes(name)) out.push(name);
        match = pattern.exec(text);
      }
      return out;
    }

    // The slots a response destroyed without displaying another view into
    // them - ["VIEW_SLOTS","destroy","POPUP"] - which is how a popup closes
    // on the wire.
    function destroyedSlots(response) {
      const system = response?.S_FRONT?.S_ACTION?.T_SYSTEM;
      if (!Array.isArray(system)) return [];
      const out = [];
      for (const item of system) {
        if (!Array.isArray(item)) continue;
        if (item[0] !== "VIEW_SLOTS" || item[1] !== "destroy") continue;
        if (typeof item[2] === "string" && !out.includes(item[2])) {
          out.push(item[2]);
        }
      }
      return out;
    }

    // The views a response displayed, reduced to what the test asserts:
    // [{ slot, ids, events }], in SLOT_ORDER plus the nested slots.
    function displayedViews(response) {
      const out = [];
      for (const slot of SLOT_ORDER.concat(["NEST", "NEST2"])) {
        const xml = Recorder.displayedXml(response, slot);
        if (!xml) continue;
        out.push({ slot, ids: idsOf(xml), events: eventsOf(xml) });
      }
      return out;
    }

    // A deep copy of the request's model delta. The delta object shares
    // references with the live model (Lib.buildDeltaFromPaths falls back
    // to a whole attribute), which the next roundtrip mutates in place -
    // and a step has to say what was sent, not what the model holds now.
    function copyDelta(model) {
      if (!model || typeof model !== "object") return null;
      let text;
      try {
        text = JSON.stringify(model);
      } catch {
        return { dropped: "the model delta could not be serialized" };
      }
      if (text === undefined) return null;
      if (text.length > MAX_DELTA_CHARS) {
        return {
          dropped: `the model delta is ${text.length} characters, more than the ${MAX_DELTA_CHARS} a recorded step keeps`,
        };
      }
      return { value: JSON.parse(text) };
    }

    // One step out of the request and response of the roundtrip that just
    // rendered. Exposed for the spec through _internals.
    function readStep(oBody, response) {
      const sFront = oBody?.S_FRONT;
      const args = Array.isArray(sFront?.T_EVENT_ARG) ? sFront.T_EVENT_ARG : [];
      return {
        event: sFront?.EVENT || "",
        args: args.map((arg) =>
          typeof arg === "string" ? arg : safeJson(arg),
        ),
        delta: copyDelta(oBody?.MODEL),
        app: response?.S_FRONT?.APP || "",
        views: displayedViews(response),
        destroyed: destroyedSlots(response),
        messages: Recorder.extractMessages(response).map((m) => m.text),
        ts: new Date().toISOString(),
      };
    }

    function safeJson(value) {
      try {
        return JSON.stringify(value) ?? "";
      } catch {
        return "";
      }
    }

    function onAfterRendering(ctx) {
      try {
        const rec = journeyOf(ctx);
        const journey = current(rec);
        if (!rec?.recording || !journey) return;
        if (journey.steps.length >= MAX_STEPS) {
          journey.overflow = true;
          return;
        }
        const step = readStep(ctx.state.oBody, ctx.state.responseData);
        step.seq = journey.steps.length + 1;
        journey.steps.push(step);
        if (!journey.app && step.app) journey.app = step.app;
      } catch (e) {
        // A recorder is a diagnostic aid; it may never take the app down.
        Lib.logError("DevTools Journey: onAfterRendering failed", e);
      }
    }

    // ------------------------------------------------------------------
    // Recording
    // ------------------------------------------------------------------

    // Start a journey. The screen the developer is looking at becomes
    // step 1 - a roundtrip already answered, read from the state the way
    // the hook reads the next ones - so the exported test asserts the
    // starting screen too. Without a response yet (the tools opened on a
    // dead start) the journey begins with the first roundtrip.
    function start(ctx) {
      const rec = ensure(ctx);
      if (!rec || rec.recording) return;
      const journey = {
        app: appOf(ctx),
        startedAt: new Date().toISOString(),
        steps: [],
        overflow: false,
      };
      rec.journeys.push(journey);
      rec.recording = true;
      if (ctx.state?.responseData) {
        const step = readStep(ctx.state.oBody, ctx.state.responseData);
        // the screen is where the recording starts, whatever event
        // produced it: the test starts the app and asserts this screen
        step.event = "";
        step.args = [];
        step.delta = null;
        step.seq = 1;
        journey.steps.push(step);
      }
      rec.hook = () => onAfterRendering(ctx);
      Lib.registerCallback(ctx, "onAfterRendering", rec.hook);
    }

    function stop(ctx) {
      const rec = journeyOf(ctx);
      if (!rec) return;
      rec.recording = false;
      if (rec.hook) {
        Lib.unregisterCallback(ctx, "onAfterRendering", rec.hook);
        rec.hook = null;
      }
      // a recording that never saw a roundtrip is no journey
      const journey = current(rec);
      if (journey && !journey.steps.length) rec.journeys.pop();
    }

    function clear(ctx) {
      stop(ctx);
      const rec = journeyOf(ctx);
      if (rec) rec.journeys = [];
    }

    function getJourneys(ctx) {
      return journeyOf(ctx)?.journeys || [];
    }

    function stepCount(ctx) {
      return getJourneys(ctx).reduce((sum, j) => sum + j.steps.length, 0);
    }

    // ------------------------------------------------------------------
    // The ABAP Unit class
    // ------------------------------------------------------------------

    // An ABAP string literal in backticks, or null when the value cannot be
    // one (a line break or a control character has no spelling inside a
    // literal - those go through set_json( ) as JSON). A long literal is
    // split into chunks joined with &&, one per line, at `indent`.
    function literal(value, indent) {
      const text = String(value);
      // eslint-disable-next-line no-control-regex
      if (/[\u0000-\u001f\u007f]/.test(text)) return null;
      const escaped = text.replace(/`/g, "``");
      if (escaped.length <= LITERAL_CHUNK) return `\`${escaped}\``;
      const chunks = [];
      let i = 0;
      while (i < escaped.length) {
        // never split a doubled backtick
        let end = Math.min(i + LITERAL_CHUNK, escaped.length);
        if (escaped[end - 1] === "`" && escaped[end] === "`") end += 1;
        chunks.push(`\`${escaped.slice(i, end)}\``);
        i = end;
      }
      return chunks.join(` &&\n${" ".repeat(indent)}`);
    }

    // A JSON value as the argument of set_json( ): the JSON text as a
    // literal. JSON escapes its own control characters, so this always
    // succeeds.
    function jsonLiteral(value, indent) {
      return literal(JSON.stringify(value), indent);
    }

    // A simple ABAP name: what set_value( name = ... ) and set_cell( ) take
    // without a path. Anything else goes through set_json( ) with a path.
    function isPlainName(name) {
      return /^[A-Za-z_][A-Za-z0-9_]*$/.test(name);
    }

    // The setter calls for one request's model delta, in the frontend's
    // shape (core/Server.js): a scalar, structure or array is the whole
    // attribute, a table cell a row delta TAB.__delta.<row>.<col> - with
    // the row counted from 0 as the model does; set_cell( ) takes ABAP's
    // 1-based row, set_json( ) the model path.
    function editStatements(delta, indent) {
      const pad = " ".repeat(indent);
      const out = [];
      if (!delta) return out;
      if (delta.dropped) {
        out.push(`${pad}" model changes not replayed: ${delta.dropped}`);
        return out;
      }
      const model = delta.value;
      if (!model || typeof model !== "object" || Array.isArray(model)) {
        return out;
      }
      for (const [name, value] of Object.entries(model)) {
        if (isRowDelta(value)) {
          rowDeltaStatements(out, pad, name, `/${name}`, value.__delta);
        } else {
          attributeStatements(out, pad, name, value);
        }
      }
      return out;
    }

    function isRowDelta(value) {
      return (
        value !== null &&
        typeof value === "object" &&
        !Array.isArray(value) &&
        Object.keys(value).length === 1 &&
        value.__delta !== null &&
        typeof value.__delta === "object"
      );
    }

    function attributeStatements(out, pad, name, value) {
      const plain = isPlainName(name);
      if (typeof value === "string" && plain) {
        const lit = literal(value, pad.length + 24);
        if (lit !== null) {
          out.push(`${pad}sim->set_value( name  = \`${name}\``);
          out.push(`${pad}                value = ${lit} ).`);
          return;
        }
      }
      if (typeof value === "boolean" && plain) {
        out.push(`${pad}sim->set_bool( name  = \`${name}\``);
        out.push(
          `${pad}               value = ${value ? "abap_true" : "abap_false"} ).`,
        );
        return;
      }
      jsonStatement(out, pad, `/${name}`, value);
    }

    // One set_cell( ) per string cell of a table row, set_json( ) for every
    // other cell, and one more level for a table inside the row.
    function rowDeltaStatements(out, pad, table, path, rows, nested) {
      for (const [row, cells] of Object.entries(rows)) {
        const rowIndex = Number(row);
        if (!cells || typeof cells !== "object") continue;
        for (const [column, cell] of Object.entries(cells)) {
          const cellPath = `${path}/${row}/${column}`;
          if (isRowDelta(cell)) {
            rowDeltaStatements(out, pad, column, cellPath, cell.__delta, true);
            continue;
          }
          const lit =
            typeof cell === "string" ? literal(cell, pad.length + 23) : null;
          if (
            lit !== null &&
            !nested &&
            Number.isInteger(rowIndex) &&
            isPlainName(table) &&
            isPlainName(column)
          ) {
            out.push(`${pad}sim->set_cell( table  = \`${table}\``);
            out.push(`${pad}               row    = ${rowIndex + 1}`);
            out.push(`${pad}               column = \`${column}\``);
            out.push(`${pad}               value  = ${lit} ).`);
            continue;
          }
          jsonStatement(out, pad, cellPath, cell);
        }
      }
    }

    function jsonStatement(out, pad, path, value) {
      const lit = jsonLiteral(value, pad.length + 23);
      const pathLit = literal(path, pad.length + 23) || "`/`";
      out.push(`${pad}sim->set_json( path = ${pathLit}`);
      out.push(`${pad}               json = ${lit} ).`);
    }

    // The click( ) of a step: the event alone, or with its arguments.
    function clickStatement(step, indent) {
      const pad = " ".repeat(indent);
      const event = literal(step.event, indent) || "``";
      if (!step.args.length) return [`${pad}sim->click( ${event} ).`];
      const out = [`${pad}sim->click( event = ${event}`];
      const argPad = `${pad}            t_arg = VALUE #( `;
      step.args.forEach((arg, i) => {
        const lit =
          literal(arg, argPad.length + 2) ||
          jsonLiteral(arg, argPad.length + 2);
        const lead = i === 0 ? argPad : " ".repeat(argPad.length);
        const tail = i === step.args.length - 1 ? " ) )." : "";
        out.push(`${lead}( ${lit} )${tail}`);
      });
      return out;
    }

    function assertEquals(pad, exp, act) {
      const lit =
        literal(exp, pad.length + 42) || jsonLiteral(exp, pad.length + 42);
      return [
        `${pad}cl_abap_unit_assert=>assert_equals( exp = ${lit}`,
        `${pad}                                    act = ${act} ).`,
      ];
    }

    function assertTrue(pad, expression) {
      return [`${pad}cl_abap_unit_assert=>assert_true( ${expression} ).`];
    }

    // What the test checks after a step: the message the app showed, the
    // app that answered when it changed, the layer a displayed view
    // opened, and the ids - or, for a view without ids, the events - of the
    // screen the user reached.
    function assertionStatements(step, previousApp, indent) {
      const pad = " ".repeat(indent);
      const out = [];
      if (step.messages.length) {
        const last = step.messages[step.messages.length - 1];
        out.push(...assertEquals(pad, last, "sim->get_message( )"));
      }
      if (step.app && previousApp && step.app !== previousApp) {
        out.push(...assertEquals(pad, step.app, "sim->get_app( )"));
      }
      const top = SLOT_ORDER.find((slot) =>
        step.views.some((view) => view.slot === slot),
      );
      if (top) {
        out.push(...assertEquals(pad, top, "sim->get_layer( )"));
      } else if (step.destroyed.includes("POPUP")) {
        out.push(
          `${pad}cl_abap_unit_assert=>assert_initial( sim->get_popup( ) ).`,
        );
      } else if (step.destroyed.includes("POPOVER")) {
        out.push(
          `${pad}cl_abap_unit_assert=>assert_initial( sim->get_popover( ) ).`,
        );
      }
      if (!top) return out;
      // the active layer's content: MAIN comes with the nested views the
      // same response displayed, as the simulator's get_ids( ) answers it
      const active = step.views.filter((view) =>
        top === "MAIN"
          ? view.slot !== "POPUP" && view.slot !== "POPOVER"
          : view.slot === top,
      );
      const ids = unique(collect(active, "ids")).slice(0, MAX_ASSERT_IDS);
      const events = unique(collect(active, "events")).slice(
        0,
        MAX_ASSERT_EVENTS,
      );
      for (const id of ids) {
        out.push(
          ...assertTrue(
            pad,
            `sim->check_id_exists( ${literal(id, 0) || "``"} )`,
          ),
        );
      }
      if (!ids.length) {
        for (const event of events) {
          out.push(
            ...assertTrue(
              pad,
              `sim->check_event_exists( ${literal(event, 0) || "``"} )`,
            ),
          );
        }
      }
      return out;
    }

    // The ids or events of several views as one list - concat, not
    // flatMap, which no other frontend module needs either
    function collect(views, field) {
      return views.reduce((all, view) => all.concat(view[field]), []);
    }

    function unique(list) {
      return list.filter((item, i) => list.indexOf(item) === i);
    }

    // One test method per journey.
    function methodLines(journey, name) {
      const pad = "    ";
      const out = [`  METHOD ${name}.`, ""];
      const app = journey.app || journey.steps.find((s) => s.app)?.app || "";
      const first = journey.steps[0];
      out.push(
        `${pad}DATA(sim) = z2ui5_cl_frontend_simulator=>start( ${literal(app, 0) || "``"} ).`,
      );
      if (first && first.event) {
        out.push(
          `${pad}" the recording began after roundtrips this test does not replay -`,
          `${pad}" the steps below run against the fresh start above`,
        );
      }
      let previousApp = app;
      journey.steps.forEach((step, index) => {
        if (index === 0 && !step.event) {
          out.push(...assertionStatements(step, previousApp, pad.length));
          previousApp = step.app || previousApp;
          return;
        }
        out.push("");
        if (!step.event) {
          out.push(
            `${pad}" step ${step.seq}: a roundtrip without an event (reload, navigation) - not replayed`,
          );
          return;
        }
        out.push(`${pad}" step ${step.seq}: ${step.event}`);
        out.push(...editStatements(step.delta, pad.length));
        out.push(...clickStatement(step, pad.length));
        out.push(...assertionStatements(step, previousApp, pad.length));
        previousApp = step.app || previousApp;
      });
      if (journey.overflow) {
        out.push(
          "",
          `${pad}" the recording stopped taking steps after ${MAX_STEPS}`,
        );
      }
      out.push("", "  ENDMETHOD.");
      return out;
    }

    // The exported class - a .clas.testclasses.abap include. RISK LEVEL
    // DANGEROUS, honestly: the app runs through the real handler, and a
    // draft-based app writes its drafts to Z2UI5_T_01 and commits; the
    // headless-frontend README shows the in-memory store that makes such
    // a test HARMLESS.
    function buildAbapUnit(ctx) {
      const journeys = getJourneys(ctx).filter((j) => j.steps.length);
      const app = journeys[0]?.app || appOf(ctx) || "";
      const out = [
        `" Journey of ${app || "(unknown app)"}, recorded with the abap2UI5 developer tools (Ctrl+F12, Roundtrips > Journey).`,
        `" Replays it on z2ui5_cl_frontend_simulator - https://github.com/abap2UI5/headless-frontend -`,
        `" in the app's test include: no browser, no HTTP, the real handler and the real main( ).`,
        `" The test starts the app fresh and replays what the user typed (set_value / set_json / set_cell)`,
        `" and pressed (click); the assertions name the messages, layers, ids and events the screens showed.`,
        `" What never reached the backend is not here: a popup closed in the browser alone, a frontend action.`,
        `" DANGEROUS because a draft-based app writes Z2UI5_T_01 - install the in-memory store the`,
        `" headless-frontend README shows to make it HARMLESS.`,
        "CLASS ltcl_journey DEFINITION FINAL",
        "  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.",
        "",
        "  PRIVATE SECTION.",
      ];
      if (!journeys.length) {
        out.push(
          `    " no journey recorded yet - press "Record Journey", click through the app, press it again`,
        );
      }
      journeys.forEach((_j, i) => {
        out.push(
          `    METHODS journey_${i + 1} FOR TESTING RAISING cx_static_check.`,
        );
      });
      out.push("ENDCLASS.", "", "", "CLASS ltcl_journey IMPLEMENTATION.", "");
      journeys.forEach((journey, i) => {
        out.push(...methodLines(journey, `journey_${i + 1}`));
        out.push("");
      });
      out.push("ENDCLASS.");
      return out.join("\n");
    }

    // File name of the download: the include the class is pasted into.
    function exportFileName(ctx) {
      const app = (
        getJourneys(ctx)[0]?.app ||
        appOf(ctx) ||
        "journey"
      ).toLowerCase();
      return `${app}_journey.clas.testclasses.abap`;
    }

    // ------------------------------------------------------------------
    // The tab
    // ------------------------------------------------------------------

    function describeDelta(delta) {
      if (!delta) return "";
      if (delta.dropped) return "(model changes too large to keep)";
      const parts = [];
      for (const [name, value] of Object.entries(delta.value || {})) {
        if (isRowDelta(value)) {
          const rows = Object.keys(value.__delta);
          parts.push(`${name}[${rows.join(",")}]`);
        } else {
          let text =
            typeof value === "string" ? JSON.stringify(value) : safeJson(value);
          if (text.length > 40) text = `${text.slice(0, 37)}...`;
          parts.push(`${name} = ${text}`);
        }
      }
      return parts.join(", ");
    }

    function describeScreen(step) {
      const parts = [];
      for (const view of step.views) {
        let text = view.slot;
        if (view.ids.length) text += ` ids: ${view.ids.slice(0, 5).join(", ")}`;
        else if (view.events.length)
          text += ` events: ${view.events.slice(0, 5).join(", ")}`;
        parts.push(text);
      }
      for (const slot of step.destroyed) {
        if (!step.views.some((view) => view.slot === slot))
          parts.push(`${slot} closed`);
      }
      for (const message of step.messages) parts.push(`message "${message}"`);
      return parts.join("; ");
    }

    function formatJourney(ctx) {
      const journeys = getJourneys(ctx);
      const lines = [
        `Journey recorder - ${isRecording(ctx) ? "RECORDING" : "OFF"} ` +
          `(${stepCount(ctx)} step(s) in ${journeys.length} journey(s))`,
        "",
        'Press "Record Journey", click through the app, press it again to stop.',
        '"Export ABAP Unit" turns the recorded steps into a local test class that',
        "replays them on z2ui5_cl_frontend_simulator (abap2UI5/headless-frontend):",
        "set_value( ) for what was typed, click( ) for every event, assertions on",
        "the messages, layers, ids and events of the screens reached.",
        "Record from the app start for a replay that reaches the same screens.",
        "",
      ];
      if (!journeys.length) {
        lines.push("(no journey recorded yet)");
        return lines.join("\n");
      }
      journeys.forEach((journey, i) => {
        lines.push(
          `Journey ${i + 1} - ${journey.app || "(app unknown)"} - ` +
            `${journey.steps.length} step(s), started ${journey.startedAt.slice(11, 19)}` +
            `${isRecording(ctx) && i === journeys.length - 1 ? " - recording" : ""}`,
        );
        for (const step of journey.steps) {
          const event = step.event || "(start)";
          const args = step.args.length ? ` (${step.args.join(", ")})` : "";
          lines.push(`  #${String(step.seq).padEnd(4)}${event}${args}`);
          const delta = describeDelta(step.delta);
          if (delta) lines.push(`        typed:  ${delta}`);
          const screen = describeScreen(step);
          if (screen) lines.push(`        screen: ${screen}`);
        }
        if (journey.overflow) {
          lines.push(`  (stopped taking steps after ${MAX_STEPS})`);
        }
        lines.push("");
      });
      return lines.join("\n");
    }

    return {
      start,
      stop,
      clear,
      isRecording,
      getJourneys,
      stepCount,
      buildAbapUnit,
      exportFileName,
      formatJourney,
      // exposed for the unit specs
      _internals: {
        MAX_STEPS,
        MAX_ASSERT_IDS,
        MAX_DELTA_CHARS,
        readStep,
        idsOf,
        eventsOf,
        literal,
        editStatements,
      },
    };
  },
);
