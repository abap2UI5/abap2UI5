// @ts-check
const { test, expect } = require("@playwright/test");

// cc/HTMLFrame.js in a real browser, on the running app page - under the
// CSP the page ships (AGENTS.md rule 13): the app's document in a srcdoc
// frame keeps its <style>, runs none of its scripts, and its sapevent:
// links and forms reach the control as the `sapevent` event. The control's
// logic one piece at a time is node/tests/htmlFrame.spec.js.

const DOCUMENT = `<!DOCTYPE html><html><head>
<style>.title { color: rgb(255, 0, 0); }</style>
</head><body>
<h1 class="title">Repositories</h1>
<a id="go" href="sapevent:go_repo?key=4711">open</a>
<a id="away" href="#elsewhere">stay in the frame</a>
<form id="commit" action="sapevent:commit_post" method="post">
  <input name="comment" value="first commit">
  <input type="checkbox" name="push" value="X" checked>
  <button id="send" type="submit" name="action" value="commit">Commit</button>
</form>
<script>document.body.setAttribute("data-script", "ran");</script>
</body></html>`;

/** @type {import('@playwright/test').Page} */
let page;

test.beforeAll(async ({ browser }) => {
  page = await browser.newPage();
  await page.goto("http://localhost:3000/");
  // the embedded z2ui5/* modules are registered once AppState is - see
  // lib-sanitizer.spec.js
  await page.waitForFunction(
    () => !!window.sap?.ui?.require?.("z2ui5/core/AppState"),
  );
  await page.evaluate(
    (content) =>
      new Promise((resolve) => {
        const w = /** @type {any} */ (window);
        w.__htmlFrameEvents = [];
        const host = document.createElement("div");
        host.id = "htmlFrameHost";
        document.body.appendChild(host);
        w.sap.ui.require(["z2ui5/cc/HTMLFrame"], (/** @type {any} */ HTMLFrame) => {
          // the content through the setter: a settings object reads the
          // braces of the <style> as binding syntax - an app binds it
          const frame = new HTMLFrame({
            height: "20rem",
            sapevent: (/** @type {any} */ e) =>
              w.__htmlFrameEvents.push({
                action: e.getParameter("action"),
                getdata: e.getParameter("getdata"),
                postdata: e.getParameter("postdata"),
              }),
          });
          frame.setContent(content);
          frame.placeAt("htmlFrameHost");
          resolve(undefined);
        });
      }),
    DOCUMENT,
  );
  await page.frameLocator("#htmlFrameHost iframe").locator("#go").waitFor();
});

test.afterAll(async () => {
  await page.close();
});

const inFrame = () => page.frameLocator("#htmlFrameHost iframe");
const events = () =>
  page.evaluate(() => /** @type {any} */ (window).__htmlFrameEvents);

test("the document keeps its styles and runs none of its scripts", async () => {
  await expect(inFrame().locator("h1.title")).toHaveCSS("color", "rgb(255, 0, 0)");
  await expect(inFrame().locator("body")).not.toHaveAttribute("data-script", "ran");
});

test("a sapevent: link is the sapevent event, the frame stays", async () => {
  await inFrame().locator("#go").click();
  await expect.poll(events).toContainEqual({
    action: "go_repo",
    getdata: "key=4711",
    postdata: "",
  });
  await expect(inFrame().locator("#go")).toBeVisible();
});

test("a form posted to sapevent: is the event with its fields, nothing is sent", async () => {
  await inFrame().locator("input[name=comment]").fill("fix the build");
  await inFrame().locator("#send").click();
  await expect.poll(events).toContainEqual({
    action: "commit_post",
    getdata: "",
    postdata: "comment=fix+the+build&push=X&action=commit",
  });
  // the frame was not navigated by the submit
  await expect(inFrame().locator("#commit")).toBeVisible();
});

test("an ordinary link is not an event", async () => {
  const before = (await events()).length;
  await inFrame().locator("#away").click();
  expect((await events()).length).toBe(before);
});
