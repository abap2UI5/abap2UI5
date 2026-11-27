// @ts-check
const { test, expect } = require("./fixtures");

// A start that fails says so on the page. The GET page is the app of
// app_source/webapp - one z2ui5.embed.Container - and the control reports a
// failed start only through its componentFailed event: the bundle did not
// load (an inactive ICF node, an expired launchpad session that answers with
// the logon page, a proxy that blocks ?z2ui5-bundle), or the bundle could not
// create the app. Until the page's component listened to it, each of these
// was an empty page with nothing in the console.
//
// Played here by a bundle request that fails: the page has to name the
// failure, give the reload hint, and log the error.

test("a bundle that does not load leaves a message and a reload hint, and logs the error", async ({
  page,
}) => {
  const logged = [];
  page.on("console", (message) => {
    if (message.type() === "error") logged.push(message.text());
  });
  // registered after the fixture's route, so asked first: every request for
  // a bundle fails as a blocked or unreachable one does
  await page.route(
    (url) => url.searchParams.has("z2ui5-bundle"),
    (route) => route.abort(),
  );

  await page.goto("/");

  await expect(page.getByText("abap2UI5 could not be started")).toBeVisible();
  await expect(page.getByText(/no abap2UI5 frontend at /)).toBeVisible();
  await expect(page.getByText(/Reload the page to try again\./)).toBeVisible();
  expect(logged.join("\n")).toContain("abap2UI5 could not be started");
  // in the control's own area, which the failed start left empty
  await expect(
    page.locator(".z2ui5EmbedContainer .sapMMessagePage"),
  ).toHaveCount(1);
});
