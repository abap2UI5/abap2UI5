sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible control that saves the scroll positions of the controls
    // listed in `items` into the model before each roundtrip and restores
    // them after the next rendering.
    return Control.extend("z2ui5.cc.Scrolling", {
      metadata: {
        properties: {
          setUpdate: {
            type: "boolean",
            defaultValue: true,
          },
          items: {
            type: "object",
          },
        },
      },

      _getDomInnerElement(id) {
        const control = ViewSlots.byId("MAIN", id);
        if (!control) return null;
        return document.getElementById(`${control.getId()}-inner`);
      },

      _getScrollTop(item) {
        try {
          const control = ViewSlots.byId("MAIN", item.N);
          // Some controls expose a scroll delegate; prefer it when available.
          const delegate = control?.getScrollDelegate?.();
          if (delegate) return delegate.getScrollTop();
          const element = this._getDomInnerElement(item.ID);
          return element ? element.scrollTop : 0;
        } catch (e) {
          Lib.logError("Scrolling._getScrollTop: failed", e);
          return 0;
        }
      },

      setBackend() {
        const items = this.getProperty("items");
        if (!items) return;
        try {
          // Resolve the binding path so we can mark only changed entries
          // as dirty in xxChangedPaths.
          const bindingInfo = this.getBindingInfo("items");
          const bindingPath =
            bindingInfo?.parts?.[0]?.path ?? bindingInfo?.path;
          for (const [index, item] of items.entries()) {
            const scrollTop = this._getScrollTop(item);
            if (item.V !== scrollTop) {
              item.V = scrollTop;
              if (bindingPath) {
                z2ui5.xxChangedPaths.add(`${bindingPath}/${index}/V`);
              }
            }
          }
        } catch (e) {
          Lib.logError("Scrolling.setBackend: failed", e);
        }
      },

      init() {
        this._setBackendBound = this.setBackend.bind(this);
        Lib.registerCallback("onBeforeRoundtrip", this._setBackendBound);
      },

      exit() {
        Lib.unregisterCallback("onBeforeRoundtrip", this._setBackendBound);
      },

      _restoreScrollPosition(item) {
        try {
          const control = ViewSlots.byId("MAIN", item.N);
          if (control?.scrollTo) {
            control.scrollTo(item.V);
            return;
          }
          const element = this._getDomInnerElement(item.ID);
          if (element) element.scrollTop = item.V;
        } catch (e) {
          Lib.logError("Scrolling._restoreScrollPosition: failed", e);
        }
      },

      onAfterRendering() {
        if (!this._pendingScroll) return;
        this._pendingScroll = false;

        const items = this.getProperty("items");
        if (!items) return;

        try {
          for (const item of items) {
            const control = ViewSlots.byId("MAIN", item.N);
            if (!control) continue;

            // Restore immediately when rendered, otherwise once it is.
            Lib.whenRendered(control, this, () =>
              this._restoreScrollPosition(item),
            );
          }
        } catch (e) {
          Lib.logError("Scrolling.onAfterRendering: failed", e);
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oRm.openStart("span", oControl);
          oRm.style("display", "none");
          oRm.openEnd();
          oRm.close("span");

          if (!oControl.getProperty("setUpdate")) return;
          oControl.setProperty("setUpdate", false, true);
          oControl._pendingScroll = true;
        },
      },
    });
  },
);
