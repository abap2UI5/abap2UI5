// The developer tools' bug report - the whole session state as one blob.
//
// Split out of devtools/DeveloperTools.js, and rebuilt on the tab
// registry: the export used to carry a hand-written list of sections in
// its own order, with its own titles, which is how it came to name
// sections ("ROUNDTRIP HISTORY", "PREVIOUS REQUEST") that match no tab -
// its own truncation hint told the reader to open a tab that does not
// exist. Now devtools/Tabs.js decides what is exported and what a
// section is called, and this module only assembles and ships it.
//
// Pasting a report into a GitHub issue is the last step of most bug
// reports, so the Markdown form is the primary product here, not an
// afterthought: each section becomes a collapsed <details> block so a
// long report stays readable in a comment, and the code fences keep XML
// and JSON from being eaten by the markdown renderer.
sap.ui.define(
  ["z2ui5/core/Lib", "z2ui5/devtools/Recorder", "z2ui5/devtools/Tabs"],
  (Lib, Recorder, Tabs) => {
    "use strict";

    // Max characters per section; long ones are truncated so the export
    // popup's TextArea still renders.
    const MAX_SECTION = 100000;

    // Where the running app's ABAP class source is placed among the tab
    // sections. High up because it is usually the most useful context
    // when sharing an error - a reader can see the class that produced
    // it - but after the log and the history, which say what happened.
    const ABAP_SOURCE_ORDER = 55;
    const ABAP_SOURCE_TITLE = "ABAP SOURCE";

    // Assemble the plain-text report: every exported tab, in the
    // registry's export order, plus the ABAP class source that was
    // fetched asynchronously and passed in (empty when unavailable).
    function buildExport(abapSource) {
      const sections = [];
      const push = (title, content) => {
        if (!content) return;
        let body = String(content);
        if (body.length > MAX_SECTION) {
          // The hint names the SECTION, not a tab: a section title is what
          // Tabs.exportTitle produces, and for a View & Data sub-view that
          // is "POPUP MODEL" or "VIEW BINDINGS" - a slot plus an aspect,
          // which no tab is called. Pointing at the tools is enough; the
          // reader is looking at the section it names.
          body =
            `${body.slice(0, MAX_SECTION)}\n\n... [truncated ` +
            `${body.length - MAX_SECTION} more characters - the developer ` +
            `tools show the full ${title} content]`;
        }
        sections.push(`===== ${title} =====\n${body}`);
      };

      const entries = Tabs.exportTabs().map((tab) => ({
        order: tab.exportOrder,
        title: Tabs.exportTitle(tab),
        // Tabs.render is itself guarded, so one throwing source can never
        // blank the report.
        body: Tabs.render(tab.key),
      }));
      if (abapSource) {
        entries.push({
          order: ABAP_SOURCE_ORDER,
          title: ABAP_SOURCE_TITLE,
          body: abapSource,
        });
      }
      entries.sort((a, b) => a.order - b.order);
      for (const entry of entries) push(entry.title, entry.body);

      return sections.join("\n\n") || "(nothing to export)";
    }

    // The same content as a GitHub-ready issue body. `plain` is the text
    // buildExport produced - handed in by the export popup, which already
    // holds it, so the second build (every tab rendered again, the XSLT
    // over every slot's XML, the formatted model) does not run a second
    // time for the same string. The one-click path builds it here.
    function buildMarkdown(abapSource, plain = buildExport(abapSource)) {
      const blocks = plain.split(/^===== (.+) =====$/m);
      // split() yields [preamble, title, body, title, body, ...]
      const out = ["## abap2UI5 - Developer Tools export", ""];
      for (let i = 1; i < blocks.length; i += 2) {
        const title = blocks[i];
        const body = (blocks[i + 1] || "").trim();
        if (!body) continue;
        // The environment block is what a reader needs first, so it is
        // the one section that is not collapsed.
        const open = title === "ENVIRONMENT" ? " open" : "";
        const fence = title.includes("SOURCE") ? "abap" : "text";
        out.push(`<details${open}>`);
        out.push(`<summary>${title}</summary>`);
        out.push("");
        out.push(`\`\`\`${fence}`);
        out.push(body);
        out.push("```");
        out.push("");
        out.push("</details>");
        out.push("");
      }
      return out.join("\n");
    }

    // Stable, sortable file name stem for the generated downloads.
    function exportFileName(appName, extension) {
      const stamp = new Date().toISOString().replace(/[:.]/g, "-");
      return `${appName || "abap2ui5"}_${stamp}.${extension}`;
    }

    // Hand a generated text file to the browser. A copy to the clipboard
    // is fine for a short report, but a full export with payloads
    // belongs in a file that can be attached to an issue.
    function downloadText(fileName, content, mimeType) {
      try {
        const blob = new Blob([content], {
          type: `${mimeType || "text/plain"};charset=utf-8`,
        });
        const url = URL.createObjectURL(blob);
        const anchor = document.createElement("a");
        anchor.href = url;
        anchor.download = fileName;
        document.body.appendChild(anchor);
        anchor.click();
        document.body.removeChild(anchor);
        // Release the object url once the download has been handed over.
        setTimeout(() => URL.revokeObjectURL(url), 0);
      } catch (e) {
        Lib.logError("DevTools Report: download failed", e);
      }
    }

    // Say "Copied" on the button that was pressed and put its label back.
    // A copy that leaves no trace looks like a copy that did not happen.
    // Exported because the dialog's own Copy button needs the same feedback
    // (DeveloperTools.onCopyTab) - it had a second copy of these six lines.
    function confirmOnButton(oButton) {
      const original = oButton.getText();
      oButton.setText("Copied");
      setTimeout(() => {
        if (!Lib.isDestroyed(oButton)) oButton.setText(original);
      }, 1500);
    }

    // Show the whole export in a stretched popup: a read-through TextArea
    // for the eye, and the four ways it leaves the browser. Markdown is
    // the emphasized one because an issue comment is where it is going.
    function openDialog(appName, abapSource) {
      const text = buildExport(abapSource);
      sap.ui.require(
        ["sap/m/Dialog", "sap/m/TextArea", "sap/m/Button"],
        (Dialog, TextArea, Button) => {
          const area = new TextArea({
            editable: true,
            width: "100%",
            rows: 25,
            growing: false,
          });
          // Set the value explicitly (not only via the constructor) so a
          // large payload is applied reliably after the control exists.
          area.setValue(text);
          const dialog = new Dialog({
            title: "abap2UI5 - Developer Tools Export",
            stretch: true,
            content: [area],
            // The `buttons` aggregation, not beginButton/endButton: UI5
            // ignores those two as soon as `buttons` is filled.
            buttons: [
              new Button({
                text: "Copy as Markdown",
                type: "Emphasized",
                // Confirm on the button itself: this dialog is modal, so
                // a MessageToast behind it would be invisible.
                press: (oEvent) => {
                  copyMarkdown(abapSource, text);
                  confirmOnButton(oEvent.getSource());
                },
              }),
              new Button({
                text: "Copy as Text",
                press: (oEvent) => {
                  Lib.copyToClipboard(text);
                  confirmOnButton(oEvent.getSource());
                },
              }),
              // Two files, because they answer different questions: the
              // report is what a human reads, the history JSON is what
              // makes a bug reproducible (it carries the recorded
              // request/response bodies when payload recording was on).
              new Button({
                text: "Download Report",
                press: () => downloadText(exportFileName(appName, "txt"), text),
              }),
              new Button({
                text: "Download History (JSON)",
                press: () =>
                  downloadText(
                    exportFileName(appName, "json"),
                    Recorder.exportJson(),
                    "application/json",
                  ),
              }),
              new Button({
                text: "Close",
                press: () => dialog.close(),
              }),
            ],
            afterClose: () => dialog.destroy(),
          });
          dialog.open();
        },
      );
    }

    // The one-click path from the Overview tab: the finished issue body
    // on the clipboard, without going through the export popup first.
    // Returns a short result message for the caller to show.
    function copyMarkdown(abapSource, plain) {
      try {
        Lib.copyToClipboard(buildMarkdown(abapSource, plain));
        return "Bug report copied as Markdown - paste it into a GitHub issue.";
      } catch (e) {
        Lib.logError("DevTools Report: markdown export failed", e);
        return `Could not build the report: ${e?.message || e}`;
      }
    }

    return {
      buildExport,
      buildMarkdown,
      confirmOnButton,
      copyMarkdown,
      downloadText,
      exportFileName,
      openDialog,
    };
  },
);
