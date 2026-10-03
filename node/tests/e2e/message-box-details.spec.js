// @ts-check
// message_box_display( details = ... ) in a real browser, against the
// transpiled backend: the details arrive unfolded, their TEXT on screen and no
// "Show details" link left to press (expandBoxDetails in
// app/webapp/core/actions/ControlCall.js).
//
// Asked for the text, not for a visible control, because that is where it
// broke: sap.m.MessageBox put the details into its FormattedText when it built
// the box on 1.71, but from 1.120 on (_getDetailsLayout, 1.144 too) it builds
// the FormattedText empty and only the link's press handler fills it. The
// expand made the empty control visible and hid the link - an empty details
// area with no way to fill it, on every release this repository pins except
// 1.71. lib-sanitizer.spec.js only ran the sanitizer, so nothing showed it;
// the protocol's frontend conformance suite (portable.box-details) did.
//
// The fixture app lives in node/srv/zcl_tst_msgbox.clas.abap. Loaded via
// ./fixtures, so the page boots the pinned UI5 build of playwright.config.js
// - and runs on the ui5-1.71 leg as well, where the text was always there and
// must stay (offline runs: UI5_PINNED_RESOURCES, see fixtures.js).
const { test, expect } = require("./fixtures");

test("a message box shows its details at once - the text, without a link to press", async ({
  page,
}) => {
  await page.goto("/?app_start=zcl_tst_msgbox");
  await page.locator('[id$="btnShow"]').click();

  // by role: the dialog's sapMMessageBox class is newer than 1.71
  const box = page.getByRole("alertdialog");
  await expect(box).toBeVisible({ timeout: 30000 });
  await expect(box).toContainText("a box with details");

  // the details area itself, with the rendered markup in it
  const details = box.locator(".sapMMessageBoxDetails");
  await expect(details).toBeVisible();
  await expect(details).toContainText("the detail text");
  await expect(details.locator("strong")).toHaveText("detail");

  // ... and no "Show details" link standing under it
  await expect(box.locator(".sapMMessageBoxLinkText")).toBeHidden();

  // the dialog is labelled by the details, as UI5's own press handler does
  const labelledBy = (await box.getAttribute("aria-labelledby")) || "";
  const detailsId = await details.getAttribute("id");
  expect(labelledBy.split(" ")).toContain(detailsId);
});
