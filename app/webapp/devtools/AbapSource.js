// The running app's ABAP class, reached from the browser.
//
// Split out of devtools/DeveloperTools.js: fetching the class source,
// building the ADT deep link and framing the ADT endpoint are one
// subject, and none of it needs the dialog. The source cache lives here
// too - three callers want the same class text (the ABAP Source tab, the
// ADT jump's line lookup and the export), and fetching it three times
// would be three requests for one answer.
//
// Which app is running is a question about ONE component context
// (core/Context.js): every function takes it first and reads the last
// response off ctx.state. The source cache stays page-wide on purpose -
// it is keyed by the class name, and a class's source is the same
// whichever instance asks for it.
sap.ui.define(["z2ui5/devtools/Inspect"], (Inspect) => {
  "use strict";

  // { app, source } of the last SUCCESSFUL fetch - the class name is part of it
  // because a navigation swaps the app under the tools and the cached
  // source would otherwise be attributed to the new one.
  let cache = null;

  // The class name of the running app, as the backend reported it in
  // the last response. Empty before the first response arrived.
  function appName(ctx) {
    return ctx?.state?.responseData?.S_FRONT?.APP || "";
  }

  // The ADT REST endpoint that renders the running app's ABAP class
  // source. Empty when the app class name is unknown (no response yet).
  function sourceUrl(ctx) {
    const name = appName(ctx);
    if (!name) return "";
    return `${window.location.origin}/sap/bc/adt/oo/classes/${encodeURIComponent(name)}/source/main`;
  }

  // The ADT url, deep-linked at the handler of the event the last
  // roundtrip carried when that is possible: the ADT source endpoint
  // honours a "#start=<line>,<col>" anchor, and the event name is a
  // literal in the class that handles it. Needs the source in the cache
  // (the ABAP Source tab warms it); without it, or when the name is not
  // found, the plain class url is returned - the jump is a shortcut,
  // never a precondition.
  function adtUrl(ctx) {
    const url = sourceUrl(ctx);
    if (!url) return "";
    const event = ctx?.state?.oBody?.S_FRONT?.EVENT;
    if (!event || cache?.app !== appName(ctx) || !cache?.source) return url;
    const lineNumber = Inspect.findEventLine(cache.source, event);
    return lineNumber ? `${url}#start=${lineNumber},1` : url;
  }

  // Open the ABAP class source as a top-level document in a new browser
  // tab. The ADT REST endpoint renders it with syntax highlighting and
  // its own "Open in ABAP Development Tools" link; opening it top-level
  // is what lets that link's adt:// navigation reach the desktop ADT.
  // From inside the inline iframe the jump never worked - browsers
  // suppress a custom-scheme navigation started in a subframe, and some
  // systems block framing the ADT endpoint entirely (X-Frame-Options),
  // so the preview is just blank there. noopener keeps the new tab from
  // reaching back into window.opener.
  function openInAdt(ctx) {
    // Stays synchronous: a window.open after an await is treated as an
    // unrequested popup and blocked.
    const url = adtUrl(ctx);
    if (!url) return;
    window.open(url, "_blank", "noopener,noreferrer");
  }

  // The iframe markup for the inline preview (what the core:HTML control
  // of the dialog is fed), or "" when the class is unknown. Built as an
  // element and serialized, never as a string with the url pasted in:
  // the DOM does the attribute escaping, so nothing here has to reason
  // about what the class name may contain.
  function iframeHtml(ctx) {
    const url = sourceUrl(ctx);
    if (!url) return "";
    const iframe = document.createElement("iframe");
    iframe.setAttribute("src", url);
    iframe.setAttribute("style", "width:100%;height:85vh;border:none;");
    return iframe.outerHTML;
  }

  // Fetch the class source via the ADT REST endpoint. Returns the raw
  // text, or "" when the class name is unknown or the request fails
  // (the endpoint needs an authenticated, ADT-enabled session, which is
  // not always available - the export must still work without it).
  // Never throws.
  async function fetchSource(ctx) {
    const url = sourceUrl(ctx);
    if (!url) return "";
    const name = appName(ctx);
    if (cache?.app === name) return cache.source;
    let source = "";
    try {
      const response = await fetch(url, {
        headers: { Accept: "text/plain" },
        credentials: "same-origin",
      });
      if (response.ok) source = await response.text();
    } catch {
      // a failed fetch leaves the "" from above - nothing to reset
    }
    // Only a SUCCESSFUL fetch is cached. A failure says nothing about the
    // class, it says something about the SESSION: the endpoint needs an
    // authenticated, ADT-enabled one, and a single 401 before the
    // developer had logged on used to be remembered for the rest of the
    // session - Report a Bug, Export and the ADT deep link then stayed
    // sourceless no matter how often they were pressed. An empty answer
    // is retried on the next request instead; that is one request per
    // press, and only while it keeps failing.
    if (source) cache = { app: name, source };
    return source;
  }

  return {
    appName,
    sourceUrl,
    adtUrl,
    openInAdt,
    iframeHtml,
    fetchSource,
    // exposed for the unit specs: the cache is the reason the deep link
    // can resolve a line at all, so the specs seed and clear it
    _setCache: (value) => {
      cache = value;
    },
  };
});
