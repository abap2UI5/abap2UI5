# JS unit spec inventory

> Extracted from `AGENTS.md`, which points here. The rule an agent has to
> carry is in that file: a spec loads the REAL `app/webapp` module through a
> stubbed `sap.ui.define` and never a copy. WHICH module has WHICH spec is a
> lookup — and it is the list that grows with every frontend change, so it is
> also the paragraph that made AGENTS.md's longest line.

The specs under `node/tests/` load the **real** `app/webapp` modules through a
stubbed `sap.ui.define` (`loadModule.js`, with stubbable module dependencies) —
never test a copied function. Run them without a browser:

```bash
npx playwright test -c node/playwright-unit.config.js   # npm run check:js
```

## What is covered

| Module under test | Spec | What it pins |
|---|---|---|
| `core/Lib.js` | `buildDeltaFromPaths.spec.js`, `utilHelpers.spec.js`, `sizeLimit.spec.js` | — |
| `core/AppState.js` | `appState.spec.js` | — |
| `core/ViewSlots.js` | `viewSlots.spec.js` | — |
| `core/Router.js` | `router.spec.js` | — |
| `Component.js` unload wiring | `componentUnload.spec.js` | — |
| `cc/UITableExt.js` | `uiTableExt.spec.js` | — |
| `cc/Focus.js` | `focus.spec.js` | — |
| `cc/Dirty.js` | `dirty.spec.js` | — |
| `cc/MessageManager.js` | `messageManager.spec.js` | — |
| `cc/Websocket.js` | `websocket.spec.js` | — |
| `cc/Geolocation.js` | `geolocation.spec.js` | — |
| `cc/CameraSelector.js` | `cameraSelector.spec.js` | — |
| `cc/CameraPicture.js` | `cameraPicture.spec.js` | — |
| `cc/FileUploader.js` | `fileUploader.spec.js` | — |
| `cc/UploadSetExt.js` | `uploadSetExt.spec.js` | — |
| `cc/MultiInputExt.js` | `multiInputExt.spec.js` | — |
| `cc/SmartMultiInputExt.js` | `smartMultiInputExt.spec.js` | — |
| `cc/InputExt.js` | `inputExt.spec.js` | the HTML `inputmode` written onto the inner input at render and set directly on later changes without invalidating, ABAP casing/padding normalized, an empty property leaving the DOM exactly as `sap.m.Input` rendered it (including an inputmode a release rendered itself), re-application after a re-render and on a control that had no DOM yet, and a value that is not an inputmode keyword logged once and ignored |
| `cc/Scrolling.js` | `scrolling.spec.js` | — |
| `cc/LPTitle.js` | `lpTitle.spec.js` | — |
| `cc/Favicon.js` | `favicon.spec.js` | — |
| `cc/Info.js` | `info.spec.js` | the one-shot armed in `init()` (a renderer-armed version re-fired `finished` per render and closed a rebuild loop), the retry while the device model has not propagated yet, and empty UI5 fields when `oConfig` is missing |
| `cc/History.js` | `history.spec.js` | — |
| `cc/Timer.js` | `timer.spec.js` | the arm-from-the-renderer flag, the one-shot that disarms itself, the repeating re-arm and both destroy re-checks, over a stub clock |
| `cc/Tree.js` | `tree.spec.js` | the per-`tree_id` snapshot, the guard that will not overwrite a valid one, and the restore-once-per-(snapshot, binding) rule that keeps a theme change from collapsing the user's expansions |
| `controller/App.controller.js` startup wiring | `appController.spec.js` | — |
| the message toast/box display hooks in `core/actions/ControlCall.js` | `messages.spec.js` | — |
| `devtools/DeveloperTools.js` | `developerTools.spec.js` | the dialog, composed with the REAL registry rather than a stub |
| `devtools/Tabs.js` | `devtoolsTabs.spec.js` | — |
| `devtools/Format.js` | `devtoolsFormat.spec.js` | — |
| `devtools/Report.js` | `devtoolsReport.spec.js` | — |
| `devtools/AbapSource.js` | `devtoolsAbapSource.spec.js` | — |
| `devtools/DevTools.js` | `devtoolsFacade.spec.js` | — |
| `devtools/Recorder.js` | `devtoolsRecorder.spec.js` | — |
| `devtools/Console.js` | `devtoolsConsole.spec.js` | — |
| `devtools/Inspect.js` | `devtoolsInspect.spec.js` | — |
| `devtools/Picker.js` | `devtoolsPicker.spec.js` | — |
| `devtools/LiveEdit.js` | `devtoolsLiveEdit.spec.js` | — |
| `devtools/DeveloperTools.fragment.xml` against the control that backs it | `devtoolsFragment.spec.js` | a handler the fragment names that the controller does not have, or a bound property nothing seeds, is not a syntax error anywhere and fails as a dead button on somebody's system |
| `core/ErrorView.js` | `errorView.spec.js` | — |
| `core/FrontendAction.js` incl. the composed `core/actions/` dispatch | `frontendAction.spec.js` | — |
| `core/actions/Shortcuts.js` | `frontendAction.spec.js` (through the dispatch) | the shortcut registry and `KEYBOARD_SET_MODE` — **no dedicated spec**: `normalizeShortcut` / `shortcutFromEvent` / the scope precedence are pure and untested directly |
| `core/actions/Variants.js` | `frontendAction.spec.js` (through the dispatch) | `SMART_VARIANT_INIT` incl. the retry chain and its once-per-key guard; `FILTER_BAR_VARIANT_INIT` is **not** exercised |
| `core/actions/ViewOps.js` | `frontendAction.spec.js` (through the dispatch), `focus-after-enable` e2e | `SET_FOCUS` and `START_TIMER` only — **the largest gap**: `SET_ODATA_MODEL`'s destroy handshake and `WIZARD_SET_NEXT_STEP` have no coverage at all |
| the URL-shaped handlers of `core/actions/Browser.js` through the REAL `core/Lib.js` validators | `browserActions.spec.js` | `DOWNLOAD_B64_FILE`'s protocol guard, active-`data:`-MIME block and filename sanitizer; `OPEN_NEW_TAB`'s same-origin guard and cleared `window.opener`; `URLHELPER`'s CR/LF header-injection block and the `REDIRECT` protocol guard |
| the action runners and the legacy `eF()`-string parsing in `core/actions/LegacyCustomJs.js` | `actionRunner.spec.js` | — |
| `controller/View1.controller.js` event handling, the after-render phase (model push by MODEL presence, per-response router sync) and the `core/actions/Slots.js` model fan-out | `view1Events.spec.js` | — |
| `core/Server.js` timeout handling | `serverTimeout.spec.js` | — |
| `core/Server.js` request sequencing | `serverRequestSeq.spec.js` | — |
| `core/Server.js` session-constant location cadence | `serverLocation.spec.js` | — |
| `core/Server.js` error routing outside the inner handlers (`readHttp`'s outer catch, `showRenderError`) | `serverRenderError.spec.js` | — |
| `core/Session.js` | `session.spec.js` | — |
| `core/ScrollFocus.js` focus-info capture | `focusInfo.spec.js` | — |
| `core/ScrollFocus.js` UI5-element resolution | `scrollFocus.spec.js` | incl. the pre-1.106 fallback for scroll/focus capture |
| `model/formatter.js` | `formatter.spec.js` | — |
| `model/models.js` device-model wiring | `deviceModel.spec.js` | — |
| `core/Lib.js` event-argument normalization | `eventArgs.spec.js` | — |
| `cc/Storage.js` | `storage.spec.js` | — |
| the public `Util.js` date helpers | `util.spec.js` | — |

## The rules that go with them

Those are in `AGENTS.md`, "Testing": the unit-test metadata flag in the
`.clas.xml`, the ban on skipping a test with `sy-sysid`, the `LOCAL FRIENDS`
requirement, and the rule that every `FOR TESTING` method asserts something.
