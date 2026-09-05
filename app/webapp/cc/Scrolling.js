sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible control that saves the scroll positions of the controls
    // listed in `items` into the model before each roundtrip and restores
    // them after the next rendering.
    // OBSOLETE: replaced by cs_event-scroll_to / cs_event-scroll_into_view - kept for backward compatibility.
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

      // The helpers below take the RESOLVED control, not the item's id:
      // resolving an id is a parent-chain walk over the view slots
      // (ViewSlots.byIdOfOwner), and each item used to be resolved two to
      // four times per roundtrip - once per helper on the way down.
      _getDomInnerElement(control) {
        if (!control) return null;
        return document.getElementById(`${control.getId()}-inner`);
      },

      _getScrollTop(control) {
        try {
          // Some controls expose a scroll delegate; prefer it when available.
          const delegate = control?.getScrollDelegate?.();
          if (delegate) return delegate.getScrollTop();
          const element = this._getDomInnerElement(control);
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
          // Resolve the binding path so we can mark only changed entries dirty.
          const bindingInfo = this.getBindingInfo("items");
          const bindingPath =
            bindingInfo?.parts?.[0]?.path ?? bindingInfo?.path;
          // Mark changed entries dirty on THIS control's own model - the same
          // per-model set View1 ships as the delta - not a shared global set.
          // resolved through the shared tracked-model resolver: in switch
          // mode this control's propagated DEFAULT model is the OData one,
          // which has no change set - the scroll positions then never
          // travelled
          const changedPaths = ViewSlots.trackedModel(this)?._z2ui5ChangedPaths;
          for (const [index, item] of items.entries()) {
            const control = ViewSlots.byIdOfOwner(this, item.N);
            const scrollTop = this._getScrollTop(control);
            if (item.V !== scrollTop) {
              item.V = scrollTop;
              if (bindingPath && changedPaths) {
                changedPaths.add(`${bindingPath}/${index}/V`);
              }
            }
          }
        } catch (e) {
          Lib.logError("Scrolling.setBackend: failed", e);
        }
      },

      init() {
        this._unhook = Lib.hookCallback(
          this,
          "onBeforeRoundtrip",
          "setBackend",
        );
      },

      exit() {
        this._unhook();
        this._pendingRestores?.clear();
      },

      // Restore `control` to `item.V` as soon as it has a DOM reference,
      // with at most ONE wait per control: onAfterRendering runs again on
      // every roundtrip, and a target that is not rendered yet collected
      // one rendering delegate per pass - Lib.whenRendered drops only the
      // delegate that fires, so the ones stacked behind it sit on a
      // control that may never render at all. The pending map carries the
      // LATEST item for the control, so the single wait restores the
      // current position rather than the one it was registered with.
      _restoreWhenRendered(control, item) {
        if (!this._pendingRestores) this._pendingRestores = new Map();
        const waiting = this._pendingRestores.has(control);
        this._pendingRestores.set(control, item);
        if (waiting) return;
        Lib.whenRendered(control, this, () => {
          const pending = this._pendingRestores.get(control);
          this._pendingRestores.delete(control);
          this._restoreScrollPosition(control, pending);
        });
      },

      _restoreScrollPosition(control, item) {
        try {
          // The position was captured through the scroll delegate where the
          // control has one (_getScrollTop), so it is restored through the
          // same delegate: ScrollEnablement.scrollTo(x, y) takes both axes.
          // control.scrollTo is NOT one signature - sap.m.Page.scrollTo(y)
          // but sap.m.ScrollContainer.scrollTo(x, y) - and a vertical
          // position handed to the latter as its first argument scrolled
          // the container sideways and left the vertical position at 0.
          const delegate = control?.getScrollDelegate?.();
          if (delegate?.scrollTo) {
            const left = delegate.getScrollLeft?.() ?? 0;
            delegate.scrollTo(left, item.V);
            return;
          }
          if (control?.scrollTo) {
            control.scrollTo(item.V);
            return;
          }
          const element = this._getDomInnerElement(control);
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
            const control = ViewSlots.byIdOfOwner(this, item.N);
            if (!control) continue;

            // Restore immediately when rendered, otherwise once it is.
            this._restoreWhenRendered(control, item);
          }
        } catch (e) {
          Lib.logError("Scrolling.onAfterRendering: failed", e);
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          Lib.renderInvisibleSpan(oRm, oControl);

          if (!oControl.getProperty("setUpdate")) return;
          oControl.setProperty("setUpdate", false, true);
          oControl._pendingScroll = true;
        },
      },
    });
  },
);
