#!/usr/bin/env node
/*
 * generate-linter-manifest.test — the readers that find the closed sets the
 * abap2UI5 linter mirrors.
 *
 * `check:linter-manifest` proves the committed manifest equals what the
 * readers find in this tree. It cannot prove the readers find the RIGHT
 * thing: a reader that drops a set member does so in the manifest and in the
 * check alike, both agree, and the linter is told the member is gone. These
 * are the cases the linter's own parsers were tested with until they moved
 * here (abap2UI5/linter, check-upstream, removed after #3001), turned from the
 * embedded-ABAP form into the JavaScript the readers read now - plus the
 * comment traps every one of them met once.
 *
 *   node .github/scripts/generate-linter-manifest.test.mjs   (npm run check:linter-manifest-readers)
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  moduleExports, boxTypes, clientEvents, companionControl, frozenBuilderHelpers, globalTargets,
  stringList, bindingMethods, frontendEvents, upperKeys, urlHelperActions, controlMethodKinds,
  shortcutAliases, objectsByPackage, buildManifest, problemsOf, REQUIRED,
} from "./generate-linter-manifest.mjs";

test("formatter-style modules: the shorthand methods of the returned object", () => {
  const src = "  return {\n    DateCreateObject(s) {\n      return s;\n    },\n    expandInlineIcons(text) {},\n    // if (x) {\n  };";
  assert.deepEqual(moduleExports(src), ["DateCreateObject", "expandInlineIcons"]);
});

test("GLOBAL_TARGETS: one-line and multi-line entries, comments with key: pairs skipped", () => {
  const js = [
    "    // `const GLOBAL_TARGETS = {` in the embedded carrier - a comment, not the declaration",
    "    const GLOBAL_TARGETS = {",
    "      ONE_LINER: { get: () => X, methods: { show: [\"string\"] } },",
    "      MULTI: {",
    "        get: () => Y,",
    "        methods: {",
    "          // payload: { CODE: { digits: n } }",
    "          a: [\"int\"],",
    "          b: [],",
    "        },",
    "      },",
    "    };",
  ].join("\n");
  assert.deepEqual(globalTargets(js), { ONE_LINER: ["show"], MULTI: ["a", "b"] });
});

test("lists: an array, a Set over one, and comments inside", () => {
  const js = [
    "    const FILTER_OPERATORS = new Set([",
    "      \"BT\", \"EQ\", // \"NOT_ONE\"",
    "    ]);",
    "    const CONTROL_METHOD_DENY_EXACT = [",
    "      'destroy', `exit`,",
    "    ];",
  ].join("\n");
  assert.deepEqual(stringList(js, "FILTER_OPERATORS"), ["BT", "EQ"]);
  assert.deepEqual(stringList(js, "CONTROL_METHOD_DENY_EXACT", "];"), ["destroy", "exit"]);
  assert.deepEqual(stringList(js, "NOT_DECLARED"), []);
});

test("BINDING_METHODS: method definitions only, not a helper called with the binding", () => {
  const js = "    const BINDING_METHODS = {\n      filter(binding, args) {\n        buildFilterGroups(binding, path);\n      },\n      sort(binding) {},\n    };";
  assert.deepEqual(bindingMethods(js), ["filter", "sort"]);
});

test("dispatch tables: every `const handlers = {`, de-duplicated", () => {
  const js = "    const handlers = {\n      OPEN_NEW_TAB: evOpen,\n      COPY: evCopy,\n    };\n    const handlers = {\n      COPY: evCopy2,\n      VIEW_SLOTS: evSlots,\n    };";
  assert.deepEqual(frontendEvents(js), ["OPEN_NEW_TAB", "COPY", "VIEW_SLOTS"]);
});

test("URL_POLICIES, SHORTCUT_ALIASES, evUrlHelper actions, CONTROL_METHODS kinds", () => {
  const js = [
    "    const URL_POLICIES = {\n      ALLOW_ALL: 1,\n      DENY_ALL: 2,\n    };",
    "    const SHORTCUT_ALIASES = { control: \"ctrl\", space: \" \" };",
    "    function evUrlHelper(oController, args) {\n      const actions = {\n        REDIRECT: (u) => u,\n        TRIGGER_EMAIL: (u) => u,\n      };\n    }",
    "    const CONTROL_METHODS = {\n      to: [\"pageId\", \"string\"],\n      back: [],\n    };",
  ].join("\n");
  assert.deepEqual(upperKeys(js, "URL_POLICIES"), ["ALLOW_ALL", "DENY_ALL"]);
  assert.deepEqual(shortcutAliases(js), { control: "ctrl", space: " " });
  assert.deepEqual(urlHelperActions(js), ["REDIRECT", "TRIGGER_EMAIL"]);
  assert.deepEqual(controlMethodKinds(js), { to: ["pageId", "string"], back: [] });
});

test("companion controls: properties, events, base, the OBSOLETE header", () => {
  const arrow = `sap.ui.define(
  ["sap/m/Input", "sap/m/InputRenderer", "z2ui5/core/Lib"],
  (Input, InputRenderer, Lib) => {
    // this.events: { fake: 1 } in a comment is no metadata
    return Input.extend("z2ui5.cc.InputExt", {
      metadata: {
        properties: {
          MultiInputId: { type: "string" },
          // a comment carrying a fake: pair
          checkInit: { type: "boolean", defaultValue: false },
        },
        events: {
          change: { allowPreventDefault: true, parameters: {} },
          remove: { parameters: { item: { type: "object" } } },
        },
      },
      renderer: InputRenderer,
    });
  },
);`;
  assert.deepEqual(companionControl(arrow), {
    properties: ["MultiInputId", "checkInit"], events: ["change", "remove"], base: "sap/m/Input", obsolete: null,
  });
  const classic = `sap.ui.define(['sap/ui/core/Control', 'z2ui5/core/Lib'], function (Control, Lib) {
  // OBSOLETE: replaced by the frontend event cs_event-start_timer - kept for backward compatibility.
  var Helper = Lib.extend('z2ui5.core.Helper', {});
  return Control.extend('z2ui5.cc.Timer', { metadata: {} });
});`;
  assert.deepEqual(companionControl(classic), {
    properties: [], events: [], base: "sap/ui/core/Control",
    obsolete: "replaced by the frontend event cs_event-start_timer - kept for backward compatibility.",
  });
  assert.equal(companionControl('return Control.extend("z2ui5.cc.X", {});').base, null, "no sap.ui.define: unreadable");
  assert.equal(companionControl('sap.ui.define(["sap/ui/core/Control"], (Control) => Base.extend("z2ui5.cc.X", {}));').base, null,
    "a receiver that is no dependency: unreadable");
});

test("the frozen builder's helpers: helper -> control, z2ui5 namespace only", () => {
  const abap = `CLASS z2ui5_cl_xml_view_cc IMPLEMENTATION.
  METHOD timer.
    result = mo_view.
    mo_view->_generic( name   = \`Timer\`
                       ns     = \`z2ui5\`
                       t_prop = VALUE #( ( n = \`delayMS\` v = delayms ) ) ).
  ENDMETHOD.
  METHOD lp_title.
    mo_view->_generic(
        name   = \`LPTitle\`
        ns     = \`z2ui5\` ).
  ENDMETHOD.
  METHOD demo_output.
    mo_view->_generic( ns   = \`html\`
                       name = \`style\` ).
  ENDMETHOD.
ENDCLASS.`;
  assert.deepEqual(frozenBuilderHelpers(abap), { timer: "Timer", lp_title: "LPTitle" });
});

test("cs_event: both quote forms, de-duplicated, comments and other blocks excluded", () => {
  const intf = `INTERFACE zif_x PUBLIC.
  CONSTANTS:
    BEGIN OF cs_event,
      " a comment quoting a value: VALUE \`NOT_AN_EVENT\`
      popup_close    TYPE string VALUE \`POPUP_CLOSE\`,
      hash_set       TYPE string VALUE \`SET_PUSH_STATE\`,
      set_push_state TYPE string VALUE \`SET_PUSH_STATE\`,
      legacy         TYPE string VALUE 'OLD_QUOTED',
    END OF cs_event.
  CONSTANTS:
    BEGIN OF cs_view,
      main TYPE string VALUE \`MAIN\`,
    END OF cs_view.
ENDINTERFACE.`;
  assert.deepEqual(clientEvents(intf), ["POPUP_CLOSE", "SET_PUSH_STATE", "OLD_QUOTED"]);
  assert.deepEqual(clientEvents("INTERFACE zif_y PUBLIC. ENDINTERFACE."), []);
});

test("ct_box_type: the rows of the VALUE constructor", () => {
  const abap = "    IF ct_box_type IS INITIAL.\n      ct_box_type = VALUE #( ( `show` )\n                             ( `alert` ) ( 'confirm' ) ).\n    ENDIF.";
  assert.deepEqual(boxTypes(abap), ["show", "alert", "confirm"]);
});

test("objects by package: classes, interfaces and tables, not test classes", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "manifest-objects-"));
  try {
    for (const rel of ["src/02/z2ui5_if_app.intf.abap", "src/01/02/z2ui5_cl_ui5_handler.clas.abap",
      "src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap", "src/01/01/z2ui5_t_01.tabl.xml", "src/01/01/package.devc.xml"]) {
      fs.mkdirSync(path.dirname(path.join(root, rel)), { recursive: true });
      fs.writeFileSync(path.join(root, rel), "");
    }
    assert.deepEqual(objectsByPackage(root), {
      "src/01/01": ["z2ui5_t_01"], "src/01/02": ["z2ui5_cl_ui5_handler"], "src/02": ["z2ui5_if_app"],
    });
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("this tree: every required set is found, and the committed manifest is it", () => {
  const manifest = buildManifest();
  assert.deepEqual(problemsOf(manifest), []);
  const committed = JSON.parse(fs.readFileSync(path.join(import.meta.dirname, "..", "shared", "linter-manifest.json"), "utf8"));
  assert.deepEqual(committed, manifest);
  assert.deepEqual(problemsOf({ ...manifest, bindingMethods: [] }), [
    "found nothing for 'bindingMethods' - its source moved or changed shape; fix the reader in .github/scripts/generate-linter-manifest.mjs",
  ]);
  assert.ok(REQUIRED.every((key) => key in manifest));
});
