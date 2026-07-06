CLASS z2ui5_cl_app_scrolling_js DEFINITION
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


CLASS z2ui5_cl_app_scrolling_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Lib, ViewSlots, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible control that saves the scroll positions of the controls` && |\n| &&
             `    // listed in ``items`` into the model before each roundtrip and restores` && |\n| &&
             `    // them after the next rendering.` && |\n| &&
             `    return Control.extend("z2ui5.cc.Scrolling", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          setUpdate: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          items: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getDomInnerElement(id) {` && |\n| &&
             `        const control = ViewSlots.byId("MAIN", id);` && |\n| &&
             `        if (!control) return null;` && |\n| &&
             `        return document.getElementById(``${control.getId()}-inner``);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getScrollTop(item) {` && |\n| &&
             `        try {` && |\n| &&
             `          const control = ViewSlots.byId("MAIN", item.N);` && |\n| &&
             `          // Some controls expose a scroll delegate; prefer it when available.` && |\n| &&
             `          const delegate = control?.getScrollDelegate?.();` && |\n| &&
             `          if (delegate) return delegate.getScrollTop();` && |\n| &&
             `          const element = this._getDomInnerElement(item.ID);` && |\n| &&
             `          return element ? element.scrollTop : 0;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Scrolling._getScrollTop: failed", e);` && |\n| &&
             `          return 0;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      setBackend() {` && |\n| &&
             `        const items = this.getProperty("items");` && |\n| &&
             `        if (!items) return;` && |\n| &&
             `        try {` && |\n| &&
             `          // Resolve the binding path so we can mark only changed entries` && |\n| &&
             `          // as dirty in xxChangedPaths.` && |\n| &&
             `          const bindingInfo = this.getBindingInfo("items");` && |\n| &&
             `          const bindingPath =` && |\n| &&
             `            bindingInfo?.parts?.[0]?.path ?? bindingInfo?.path;` && |\n| &&
             `          for (const [index, item] of items.entries()) {` && |\n| &&
             `            const scrollTop = this._getScrollTop(item);` && |\n| &&
             `            if (item.V !== scrollTop) {` && |\n| &&
             `              item.V = scrollTop;` && |\n| &&
             `              if (bindingPath) {` && |\n| &&
             `                AppState.state.xxChangedPaths.add(``${bindingPath}/${index}/V``);` && |\n| &&
             `              }` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Scrolling.setBackend: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `        Lib.registerCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _restoreScrollPosition(item) {` && |\n| &&
             `        try {` && |\n| &&
             `          const control = ViewSlots.byId("MAIN", item.N);` && |\n| &&
             `          if (control?.scrollTo) {` && |\n| &&
             `            control.scrollTo(item.V);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const element = this._getDomInnerElement(item.ID);` && |\n| &&
             `          if (element) element.scrollTop = item.V;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Scrolling._restoreScrollPosition: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (!this._pendingScroll) return;` && |\n| &&
             `        this._pendingScroll = false;` && |\n| &&
             `` && |\n| &&
             `        const items = this.getProperty("items");` && |\n| &&
             `        if (!items) return;` && |\n| &&
             `` && |\n| &&
             `        try {` && |\n| &&
             `          for (const item of items) {` && |\n| &&
             `            const control = ViewSlots.byId("MAIN", item.N);` && |\n| &&
             `            if (!control) continue;` && |\n| &&
             `` && |\n| &&
             `            // Restore immediately when rendered, otherwise once it is.` && |\n| &&
             `            Lib.whenRendered(control, this, () =>` && |\n| &&
             `              this._restoreScrollPosition(item),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Scrolling.onAfterRendering: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          oRm.openStart("span", oControl);` && |\n| &&
             `          oRm.style("display", "none");` && |\n| &&
             `          oRm.openEnd();` && |\n| &&
             `          oRm.close("span");` && |\n| &&
             `` && |\n| &&
             `          if (!oControl.getProperty("setUpdate")) return;` && |\n| &&
             `          oControl.setProperty("setUpdate", false, true);` && |\n| &&
             `          oControl._pendingScroll = true;` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
