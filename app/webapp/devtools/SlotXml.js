// The view XML a slot currently holds - the developer tools' one reader.
//
// The live view's own viewContent when UI5 kept it, else the source
// ViewSlots recorded when the slot was filled (a fragment or a
// `definition`-built view keeps none).
//
// Read from the SLOT, never from the last response: a slot lives and dies
// by ViewSlots.setView/destroy, and both ways of tearing one down end up
// there - the backend's ["VIEW_SLOTS","destroy",...] action and the
// roundtrip-free frontend close (cs_event-popup_close / popover_close,
// which the backend formats as that very same action). Scraping the last
// response's display action instead made the frontend close look like a
// popup that was still open: no roundtrip happens, so the response that
// opened it stayed the current one.
//
// Private member access, developer tools only: XMLView keeps the raw XML
// as a pseudo property in mProperties but does not declare it in its
// metadata, so getProperty("viewContent") throws (#2318 switched to
// getProperty and broke the View tab). The plain object is read instead.
//
// One module because three had the same read - the tab registry
// (devtools/Tabs.js), the registry inspector (devtools/Inspect.js) and the
// control picker (devtools/Picker.js) - and could not borrow it from each
// other: Tabs depends on Inspect and on Picker, so an import in either
// direction closed a cycle. Below all three, with the slot registry as its
// only dependency, it sits where every reader can reach it.
sap.ui.define(["z2ui5/core/ViewSlots"], (ViewSlots) => {
  "use strict";

  function viewContent(view) {
    return view?.mProperties?.viewContent;
  }

  // "" for an unknown or empty slot, and for no slot at all (a picked
  // control outside every slot). `ctx` is the component context whose
  // slots are read (core/Context.js).
  function slotXml(ctx, slotKey) {
    if (!slotKey) return "";
    return (
      viewContent(ViewSlots.getView?.(ctx, slotKey)) ||
      ViewSlots.getViewXml?.(ctx, slotKey) ||
      ""
    );
  }

  return { viewContent, slotXml };
});
