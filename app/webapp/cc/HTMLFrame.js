// A document of its own - HTML the app wrote, with its own styles - shown in
// an iframe beside the controls of the view, and the links and forms in it
// that talk back to the app. This is what cl_gui_html_viewer is in the SAP
// GUI: a report (abapGit, an HTML dashboard) builds a whole page and reacts
// to `sapevent:` links and to forms posted to a `sapevent:` action.
//
//   content   - the document, a complete HTML page or a fragment. Bind it
//               (client->_bind( mv_html )): written into the view as a
//               literal, the braces of its CSS would be read as binding
//               syntax. A change renders the frame anew.
//   width     - CSS size of the frame (default 100%)
//   height    - CSS size of the frame (default 30rem)
//   title     - the frame's accessible name
//   sapevent  - fired for a click on <a href="sapevent:action?query"> and
//               for the submit of a <form action="sapevent:action">, with
//                 action   - what follows `sapevent:` up to the `?`
//                 getdata  - the query of the link, or of a form sent with
//                            method get
//                 postdata - the fields of a form sent with method post,
//                            urlencoded (a=1&b=2) as the SAP GUI hands them
//               An app takes them as event arguments:
//                 `${$parameters>/action}` and so on.
//
// SECURITY - what keeps script out of the frame is the page's CSP, not the
// sandbox. A srcdoc frame inherits the page's policy (AGENTS.md rule 13), so
// the document's inline <script>, an onclick= or a javascript: URL is
// refused by the browser - the same as for HTML in the page itself, which an
// app can already put there unsanitized with sap.ui.core.HTML; the frame
// opens nothing the page did not. The sandbox has to allow scripts all the
// same: WebKit calls no listener at all on a document whose frame forbids
// them - not even this control's, which run in the page - so without
// allow-scripts no click and no submit would reach the app in Safari (the
// html-frame e2e caught it). allow-same-origin lets the control reach into
// the document for those listeners; together with allow-scripts it no
// longer confines a script, which is why the policy is the guard. Whoever
// changes the page's CSP for inline script changes it for the frame too.
// allow-forms makes a submit fire at all (the browser drops a sandboxed
// form before its submit event otherwise); every submit is cancelled, the
// document is never navigated by a form. allow-popups (with
// -to-escape-sandbox) lets a link with target=_blank open its address in a
// tab of its own; a link inside the frame navigates the frame only - no
// allow-top-navigation. A `sapevent:` link is cancelled and becomes the
// event.
//
// The control decides nothing (AGENTS.md rule 10): it fires what was clicked
// and the app answers with a new `content`.
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/Env"],
  (Control, Lib, Env) => {
    "use strict";

    const SANDBOX =
      "allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox";
    const SCHEME = "sapevent:";
    // the documents the listeners are on - the empty initial one of a frame
    // and the one of its content, each wired once
    const wired = new WeakSet();

    // "sapevent:action?a=1" -> { action, getdata }; null for another address
    function parseSapevent(href) {
      const value = String(href || "").trim();
      if (value.slice(0, SCHEME.length).toLowerCase() !== SCHEME) return null;
      const rest = value.slice(SCHEME.length);
      const q = rest.indexOf("?");
      return q < 0
        ? { action: rest, getdata: "" }
        : { action: rest.slice(0, q), getdata: rest.slice(q + 1) };
    }

    // the fields of a form, urlencoded as a browser would send them - the
    // button that submitted it included, as the browser does
    function formData(form, submitter) {
      const params = new URLSearchParams();
      for (const el of Array.from(form.elements || [])) {
        if (!el.name || el.disabled) continue;
        const type = String(el.type || "").toLowerCase();
        if (["submit", "button", "image", "reset", "file"].includes(type)) {
          continue;
        }
        if ((type === "checkbox" || type === "radio") && !el.checked) continue;
        if (el.tagName === "SELECT" && el.multiple) {
          for (const opt of Array.from(el.options)) {
            if (opt.selected) params.append(el.name, opt.value);
          }
          continue;
        }
        params.append(el.name, el.value);
      }
      if (submitter && submitter.name) {
        params.append(submitter.name, submitter.value || "");
      }
      return params.toString();
    }

    const HTMLFrame = Control.extend("z2ui5.cc.HTMLFrame", {
      metadata: {
        properties: {
          content: { type: "string", defaultValue: "" },
          width: { type: "sap.ui.core.CSSSize", defaultValue: "100%" },
          height: { type: "sap.ui.core.CSSSize", defaultValue: "30rem" },
          title: { type: "string", defaultValue: "" },
        },
        events: {
          sapevent: {
            parameters: {
              action: { type: "string" },
              getdata: { type: "string" },
              postdata: { type: "string" },
            },
          },
        },
      },

      onAfterRendering() {
        const frame = this.getDomRef();
        if (!frame) return;
        // srcdoc loads asynchronously: the document there now is the empty
        // initial one, the content's arrives with load - wire both, the
        // listeners go with whichever document they were put on
        frame.addEventListener("load", () => this._wire(frame));
        this._wire(frame);
      },

      _wire(frame) {
        if (Lib.isDestroyed(this)) return;
        let doc;
        try {
          doc = frame.contentDocument;
        } catch (e) {
          Lib.logError(
            "HTMLFrame: the document of the frame is out of reach",
            e,
          );
          return;
        }
        if (!doc || wired.has(doc)) return;
        wired.add(doc);
        doc.addEventListener("click", (e) => this._onClick(e), true);
        doc.addEventListener("submit", (e) => this._onSubmit(e), true);
      },

      _onClick(e) {
        const link = e.target?.closest?.("a[href]");
        if (!link) return;
        const parsed = parseSapevent(link.getAttribute("href"));
        if (!parsed) return;
        e.preventDefault();
        this.fireSapevent({ ...parsed, postdata: "" });
      },

      _onSubmit(e) {
        const form = e.target;
        // a form is never sent anywhere from the frame
        e.preventDefault();
        if (!form || form.tagName !== "FORM") return;
        const parsed = parseSapevent(form.getAttribute("action"));
        if (!parsed) {
          Lib.logError(
            `HTMLFrame: a form to ${form.getAttribute("action")} is not sent - only sapevent: actions are`,
          );
          return;
        }
        const data = formData(form, e.submitter);
        const get =
          String(form.getAttribute("method") || "").toLowerCase() === "get";
        this.fireSapevent({
          action: parsed.action,
          getdata: get
            ? [parsed.getdata, data].filter(Boolean).join("&")
            : parsed.getdata,
          postdata: get ? "" : data,
        });
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oRm.openStart("iframe", oControl);
          oRm.attr("sandbox", SANDBOX);
          oRm.attr("srcdoc", oControl.getContent());
          oRm.attr("title", oControl.getTitle());
          oRm.style("width", oControl.getWidth());
          oRm.style("height", oControl.getHeight());
          oRm.style("border", "0");
          oRm.style("display", "block");
          oRm.openEnd();
          oRm.close("iframe");
        },
      },
    });

    // for the specs
    HTMLFrame._parseSapevent = parseSapevent;
    HTMLFrame._formData = formData;

    return Env.ownClass(HTMLFrame);
  },
);
