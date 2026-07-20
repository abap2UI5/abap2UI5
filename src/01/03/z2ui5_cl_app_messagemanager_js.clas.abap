CLASS z2ui5_cl_app_messagemanager_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_messagemanager_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "sap/ui/core/message/Message",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Message, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // A message key that is stable across a round-trip: two rows describing` && |\n| &&
             `    // the same problem (same text, type and target) map to the same key, so` && |\n| &&
             `    // reconciling never adds a duplicate or drops a still-wanted message.` && |\n| &&
             `    const keyOf = (o) =>` && |\n| &&
             `      [o.MESSAGE ?? o.message, o.TYPE ?? o.type, o.TARGET ?? o.target].join("");` && |\n| &&
             `` && |\n| &&
             `    // Invisible companion control that bridges the UI5 message manager to a` && |\n| &&
             `    // two-way bound ABAP table (``items``). The table is the app's OWN messages:` && |\n| &&
             `    // on every backend update the control reconciles the message manager to` && |\n| &&
             `    // match it - adding new rows as sap.ui.core.message.Message objects (with` && |\n| &&
             `    // a target + the view's model as processor, so they set the bound field's` && |\n| &&
             `    // valueState) and removing the app rows that are gone. Messages the` && |\n| &&
             `    // framework auto-collects from binding-type/constraint validation stay in` && |\n| &&
             `    // the message> model untouched; a MessagePopover bound to {message>/}` && |\n| &&
             `    // shows both. Mirrors the MultiInputExt companion-control pattern.` && |\n| &&
             `    return Control.extend("z2ui5.cc.MessageManager", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          items: { type: "object" },` && |\n| &&
             `          checkInit: { type: "boolean", defaultValue: false },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          change: { allowPreventDefault: true, parameters: {} },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        // Messages this control has added, by key, so it removes exactly its` && |\n| &&
             `        // own rows and never touches auto-collected validation messages.` && |\n| &&
             `        this._added = new Map();` && |\n| &&
             `        this._ready = false;` && |\n| &&
             `        this._setupBound = this.setup.bind(this);` && |\n| &&
             `        Lib.registerCallback("onAfterRendering", this._setupBound);` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onAfterRendering", this._setupBound);` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `` && |\n| &&
             `      setup() {` && |\n| &&
             `        if (this.getProperty("checkInit")) return;` && |\n| &&
             `        const messaging = Lib.getMessaging?.();` && |\n| &&
             `        if (!messaging) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        this._messaging = messaging;` && |\n| &&
             `        const view = ViewSlots.getView(` && |\n| &&
             `          ViewSlots.containingSlotKey(this) ?? "MAIN",` && |\n| &&
             `        );` && |\n| &&
             `        this._processor = view?.getModel?.() ?? null;` && |\n| &&
             `        this._ready = true;` && |\n| &&
             `        // reconcile whatever arrived before the control was ready` && |\n| &&
             `        this.reconcile();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // property setter override: the two-way binding calls this when the` && |\n| &&
             `      // backend ships a new message table (base setProperty is used for the` && |\n| &&
             `      // internal store, so it never re-enters here)` && |\n| &&
             `      setItems(aItems) {` && |\n| &&
             `        this.setProperty("items", aItems, true);` && |\n| &&
             `        if (this._ready) this.reconcile();` && |\n| &&
             `        return this;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Bring the message manager in line with the ``items`` table: add rows` && |\n| &&
             `      // that are not yet present, remove the control's own rows that are gone.` && |\n| &&
             `      reconcile() {` && |\n| &&
             `        const rows = this.getProperty("items") || [];` && |\n| &&
             `        const wanted = new Map(rows.map((r) => [keyOf(r), r]));` && |\n| &&
             `` && |\n| &&
             `        // remove app rows no longer wanted` && |\n| &&
             `        for (const [key, oMessage] of this._added) {` && |\n| &&
             `          if (!wanted.has(key)) {` && |\n| &&
             `            this._messaging.removeMessages(oMessage);` && |\n| &&
             `            this._added.delete(key);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        // add newly wanted rows` && |\n| &&
             `        for (const [key, r] of wanted) {` && |\n| &&
             `          if (this._added.has(key)) continue;` && |\n| &&
             `          const oMessage = new Message({` && |\n| &&
             `            message: r.MESSAGE ?? "",` && |\n| &&
             `            description: r.DESCRIPTION ?? "",` && |\n| &&
             `            type: r.TYPE ?? "Error",` && |\n| &&
             `            target: r.TARGET ?? "",` && |\n| &&
             `            additionalText: r.ADDITIONALTEXT ?? "",` && |\n| &&
             `            processor: this._processor,` && |\n| &&
             `          });` && |\n| &&
             `          this._messaging.addMessages(oMessage);` && |\n| &&
             `          this._added.set(key, oMessage);` && |\n| &&
             `        }` && |\n| &&
             `        this.fireChange();` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
