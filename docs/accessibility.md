# Accessibility

What abap2UI5 contributes to the accessibility of an app, what it leaves to
UI5, and what the app has to do. Like [security.md](security.md), every
sentence below that makes a claim about the shipped code names the module or
the test that holds the code to it; nothing here is a conformance claim the
repository cannot back.

## Who does what

| Part | Whose | What that means |
|---|---|---|
| The controls: keyboard handling, ARIA roles and states, focus order inside a control, screen-reader texts, right-to-left, the high-contrast themes | **UI5's** | An abap2UI5 view is a standard UI5 XML view, created with `XMLView.create`, and every standard control renders through its own UI5 renderer. abap2UI5 adds no rendering of its own to a standard control, so a control is exactly as accessible as UI5 makes it on the release the system runs. SAP publishes the accessibility of UI5 per release. |
| The frame around the views: the roundtrip, focus and scroll across a re-render, announcements of a backend change, the error overlay | **abap2UI5's** | Listed below, each with its test. |
| The content: labels, texts, tooltips, reading order, colour, the choice of controls | **The app's** | Listed under "What the app has to do". |

## What the framework guarantees

| Guarantee | How | Held to the code by |
|---|---|---|
| The focus survives a roundtrip | The frontend sends the focused control and the caret position with each event (`S_FOCUS`, `core/ScrollFocus.js`) and puts the focus back after the view is re-rendered, so a keyboard user does not start again at the top of the page after every event | `focusInfo.spec.js`, `scrollFocus.spec.js` ([test inventory](agents/test-inventory.md)) |
| The app can move the focus | `client->follow_up_action( )` with `cs_event-set_focus` focuses a control by id after the roundtrip, also a field the same roundtrip has just enabled | [focus-after-enable.spec.js](../node/tests/e2e/focus-after-enable.spec.js) |
| The app can announce a change | `INVISIBLE_MESSAGE` `announce` reads a text out to a screen reader without rendering it (`sap.ui.core.InvisibleMessage`, UI5 1.78 and later; on an older release the call is skipped, never an error) — the one way to announce a change the backend made that has no control of its own | The action whitelist in `core/actions/ControlCall.js`, [frontendAction.spec.js](../node/tests/frontendAction.spec.js) (also: an older release reports instead of throwing) |
| The app can switch to a high-contrast theme | `THEMING` `setTheme` with `sap_horizon_hcb` / `sap_horizon_hcw` (or the Belize and Fiori 3 variants on older releases) at runtime, for example from a user setting | The action whitelist in `core/actions/ControlCall.js`, [frontendAction.spec.js](../node/tests/frontendAction.spec.js) |
| A crash is announced, not silent | The fatal-error overlay is an `alertdialog` with `aria-modal` and a label, takes the focus to its primary action, keeps Tab inside itself and takes the focus back when the broken page behind it moves it | [error-view.spec.js](../node/tests/e2e/error-view.spec.js) |
| Message details are readable | The details of a message box are shown unfolded, as text, on 1.71 and on the current release, where UI5 itself creates the details text empty until a link is pressed | [message-box-details.spec.js](../node/tests/e2e/message-box-details.spec.js) |

## What the app has to do

The framework cannot know what a field means. These are the app's, as they
are in any UI5 app:

1. **A label for every input.** A `Label` with `labelFor`, or a `SimpleForm` /
   `Form`, which associates the two itself.
2. **A name for every control that has no text.** An icon-only `Button`
   carries a `tooltip` (or `ariaLabelledBy`); an `Image` that carries meaning
   is `decorative="false"` with an `alt`. The [abap2UI5 linter](https://github.com/abap2UI5/linter)
   reports both cases as `missing-accessibility`, on every pull request of a
   repository that runs it.
3. **Meaning not in colour alone.** A `state` (`Error`, `Warning`, `Success`)
   comes with a text that says the same, as `ObjectStatus` and the message
   strip do with their text.
4. **Messages through the message channels.** `message_box_display`,
   `message_toast_display` and the value state of an input reach a screen
   reader; a red `Text` does not.
5. **Announce what changes off-screen.** When an event changes something the
   user is not looking at — a total, a status in a list — announce it with
   `INVISIBLE_MESSAGE`.

## What is not claimed

- **No conformance statement for an app.** WCAG 2.1 and EN 301 549
  conformance is a property of an app on a UI5 release, tested by whoever owns
  the app. abap2UI5 is a framework; it has no conformance level of its own to
  declare, and this page does not declare one.
- **No audit by a third party** of the framework's own parts has been made.
  The guarantees above are what its tests hold it to on every merge.
- **Custom controls** (`app/webapp/cc/`) are mostly non-visual bridges
  (storage, geolocation, websocket, the message manager) or extensions of a
  standard control that keep its renderer (`InputExt`, `CameraSelector`).
  The ones that render something build it from standard controls — the
  camera trigger is a `sap.m.Button` with icon and text, the file uploader
  a plain `div` around an `HBox` of standard controls. A custom control that renders markup of its own is
  reviewed as such when it is added.

Report an accessibility problem in the framework as a
[bug](https://github.com/abap2UI5/abap2UI5/issues/new/choose); one in a
standard control belongs to [UI5](https://github.com/SAP/openui5/issues).
