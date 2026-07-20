sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/message/Message",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
  ],
  (Control, Message, Lib, ViewSlots) => {
    "use strict";

    // A message key that is stable across a round-trip: two rows describing
    // the same problem (same text, type and target) map to the same key, so
    // reconciling never adds a duplicate or drops a still-wanted message.
    const keyOf = (o) =>
      [o.MESSAGE ?? o.message, o.TYPE ?? o.type, o.TARGET ?? o.target].join("");

    // Invisible companion control that bridges the UI5 message manager to a
    // two-way bound ABAP table (`items`). The table is the app's OWN messages:
    // on every backend update the control reconciles the message manager to
    // match it - adding new rows as sap.ui.core.message.Message objects (with
    // a target + the view's model as processor, so they set the bound field's
    // valueState) and removing the app rows that are gone. Messages the
    // framework auto-collects from binding-type/constraint validation stay in
    // the message> model untouched; a MessagePopover bound to {message>/}
    // shows both. Mirrors the MultiInputExt companion-control pattern.
    return Control.extend("z2ui5.cc.MessageManager", {
      metadata: {
        properties: {
          items: { type: "object" },
          checkInit: { type: "boolean", defaultValue: false },
        },
        events: {
          change: { allowPreventDefault: true, parameters: {} },
        },
      },

      init() {
        // Messages this control has added, by key, so it removes exactly its
        // own rows and never touches auto-collected validation messages.
        this._added = new Map();
        this._ready = false;
        this._setupBound = this.setup.bind(this);
        Lib.registerCallback("onAfterRendering", this._setupBound);
      },
      exit() {
        Lib.unregisterCallback("onAfterRendering", this._setupBound);
      },
      renderer: { apiVersion: 2, render() {} },

      setup() {
        if (this.getProperty("checkInit")) return;
        const messaging = Lib.getMessaging?.();
        if (!messaging) return;
        this.setProperty("checkInit", true);
        this._messaging = messaging;
        const view = ViewSlots.getView(
          ViewSlots.containingSlotKey(this) ?? "MAIN",
        );
        this._processor = view?.getModel?.() ?? null;
        this._ready = true;
        // reconcile whatever arrived before the control was ready
        this.reconcile();
      },

      // property setter override: the two-way binding calls this when the
      // backend ships a new message table (base setProperty is used for the
      // internal store, so it never re-enters here)
      setItems(aItems) {
        this.setProperty("items", aItems, true);
        if (this._ready) this.reconcile();
        return this;
      },

      // Bring the message manager in line with the `items` table: add rows
      // that are not yet present, remove the control's own rows that are gone.
      reconcile() {
        const rows = this.getProperty("items") || [];
        const wanted = new Map(rows.map((r) => [keyOf(r), r]));

        // remove app rows no longer wanted
        for (const [key, oMessage] of this._added) {
          if (!wanted.has(key)) {
            this._messaging.removeMessages(oMessage);
            this._added.delete(key);
          }
        }
        // add newly wanted rows
        for (const [key, r] of wanted) {
          if (this._added.has(key)) continue;
          const oMessage = new Message({
            message: r.MESSAGE ?? "",
            description: r.DESCRIPTION ?? "",
            type: r.TYPE ?? "Error",
            target: r.TARGET ?? "",
            additionalText: r.ADDITIONALTEXT ?? "",
            processor: this._processor,
          });
          this._messaging.addMessages(oMessage);
          this._added.set(key, oMessage);
        }
        this.fireChange();
      },
    });
  },
);
