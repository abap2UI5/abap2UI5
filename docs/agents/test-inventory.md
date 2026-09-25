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
| `core/Lib.js` rendering and timer helpers | `libRendering.spec.js` | `onNextRendering`/`whenRendered` - one pending delegate per control and key (a keyed call replaces, an unkeyed one stacks, a dead owner is dropped), `usesXmlTemplating` - the templating namespace under any prefix or a `template>` binding, and `cancelTimer`/`cancelPendingTimers` - a slot holding a setTimeout handle or an afterRoundtrip cancel |
| `core/Env.js` Theming/Localization probes | `libEnvProbes.spec.js` | `getThemingModule`/`getTheme`/`getLocale` - the 1.118+ module branch, the 1.71 Configuration fallback, and the never-throw bare-bootstrap answer shared by Component, Inspect and the THEMING action target |
| `core/Env.js` element registry, messaging and fragment preload | `utilHelpers.spec.js` (`loadEnv`) | `getElementById`, `getMessaging`/`hasMessagingModule` (the 1.118 Messaging module vs. the MessageManager fallback, and an unreadable version meaning "modern"), `fragmentLoadsSync`/`fragmentControlModules`/`preloadFragmentModules` (the 1.71-1.82 synchronous-fragment workaround) |
| `core/Context.js` | `context.spec.js` | one context per component, `of` through a controller, the component, the owner component or the parent chain to a slot view, `destroy` reading dead and rebuilding the state, `runAsOwner` |
| `core/AppState.js` | `appState.spec.js` | the shape of a component's state: `createState` defaults, fresh containers per call, prototype-less wire-keyed records, no state of its own |
| `core/ViewSlots.js` | `viewSlots.spec.js` | — |
| `core/Router.js` | `router.spec.js` | — |
| `Component.js` unload wiring | `componentUnload.spec.js` | — |
| `Component.js` component data | `componentData.spec.js` | the frontend settings split off in `init` - `checkLocal`, the two resource roots and a host's `endpoint` land in the state and never in the `ComponentData` sent to the backend; an `endpoint` among the launchpad's `startupParameters` is not taken |
| `reuse/Container.js` | `reuseContainer.spec.js` | the host-side control: the stylesheet included once at module load, nothing started while `app` is empty, the component data in the launchpad's shape with `endpoint` on the top level (and none without one), a changed start property replacing the component while an unchanged one keeps it |
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
| `controller/App.controller.js` startup wiring | `appController.spec.js` | the backend URL - a host's `endpoint` before the page URL of the GET page before the manifest's data source |
| the message toast/box display hooks in `core/actions/ControlCall.js` | `messages.spec.js` | — |
| `core/actions/BindingCall.js` | `frontendAction.spec.js` (`BINDING_CALL`) | the filter/sorter whitelist through the real dispatch: single and compound filter groups, the operator whitelist, clearing on empty values, the sorter flags |
| `devtools/DeveloperTools.js` | `developerTools.spec.js` | the dialog, composed with the REAL registry rather than a stub |
| `devtools/Tabs.js` | `devtoolsTabs.spec.js` | — |
| `devtools/Format.js` | `devtoolsFormat.spec.js` | — |
| `devtools/Report.js` | `devtoolsReport.spec.js` | — |
| `devtools/AbapSource.js` | `devtoolsAbapSource.spec.js` | — |
| `devtools/DevTools.js` | `devtoolsFacade.spec.js` | — |
| `devtools/Recorder.js` | `devtoolsRecorder.spec.js` | — |
| `devtools/Console.js` | `devtoolsConsole.spec.js` | — |
| `devtools/Inspect.js` | `devtoolsInspect.spec.js` | the Overview, Environment, Registry, Actions and Error reports, and that the inspectors of their own module (below) answer through `Inspect` as well |
| `devtools/Log.js` | `devtoolsLog.spec.js` | the Log tab: the three sources merged into one timeline, the origin column, the level counts the Overview reads |
| `devtools/Bindings.js` | `devtoolsBindings.spec.js` | the Bindings tab: the missing-path check, the size ranking, the delta preview built with the real `Lib.buildDeltaFromPaths`, one slot per call |
| `devtools/Help.js` | `devtoolsInspect.spec.js` (through `Inspect.formatHelp`) | — |
| `devtools/Diff.js` | `devtoolsDiff.spec.js` | the two pure diff walks - changed/added/removed paths, table rows by index, the depth and entry caps; the resync window of the line diff |
| `devtools/Persist.js` | `devtoolsPersist.spec.js` | the guarded sessionStorage access every devtools module shares - a throwing or missing storage answers the default and never the caller, a carried-over list is consumed on read |
| `devtools/SlotXml.js` | `devtoolsSlotXml.spec.js` | the one slot-XML reader of the tools: the live view's XML over the recorded source, and never through `getProperty` |
| `devtools/Picker.js` | `devtoolsPicker.spec.js` | — |
| `devtools/LiveEdit.js` | `devtoolsLiveEdit.spec.js` | — |
| `devtools/DeveloperTools.fragment.xml` against the control that backs it | `devtoolsFragment.spec.js` | a handler the fragment names that the controller does not have, or a bound property nothing seeds, is not a syntax error anywhere and fails as a dead button on somebody's system |
| `core/ErrorView.js` | `errorView.spec.js` | — |
| `core/FrontendAction.js` incl. the composed `core/actions/` dispatch | `frontendAction.spec.js` | — |
| `core/actions/Shortcuts.js` | `frontendAction.spec.js` (through the dispatch) | the shortcut registry — **no dedicated spec**: `normalizeShortcut` / `shortcutFromEvent` / the scope precedence are pure and untested directly. `KEYBOARD_SET_MODE` used to be the module's second handler and was removed on 2026-09-22 (`cc/InputExt.js` carries `inputmode` as a bound property instead, covered by `inputExt.spec.js`) |
| `core/actions/Variants.js` | `frontendAction.spec.js` (through the dispatch) | `SMART_VARIANT_INIT` incl. the retry chain and its once-per-key guard, and `FILTER_BAR_VARIANT_INIT` (its own describe block) |
| `core/actions/ViewOps.js` | `frontendAction.spec.js` (through the dispatch), `focus-after-enable` e2e | `SET_FOCUS` and `START_TIMER` here; `SET_ODATA_MODEL`'s destroy handshake and the on-first-use client load are in `view1Events.spec.js` (the OData ownership block) |
| the URL-shaped handlers of `core/actions/Browser.js` through the REAL `core/Lib.js` validators | `browserActions.spec.js` | `DOWNLOAD_B64_FILE`'s protocol guard, active-`data:`-MIME block and filename sanitizer; `OPEN_NEW_TAB`'s same-origin guard and cleared `window.opener`; `URLHELPER`'s CR/LF header-injection block and the `REDIRECT` protocol guard |
| `core/actions/Launchpad.js` through the REAL `core/Lib.js` validators | `launchpad.spec.js` | `CROSS_APP_NAV_TO_PREV_APP`/`CROSS_APP_NAV_TO_EXT` against the `oLaunchpad` navigator on the spec context (the no-op-with-log outside the FLP, the `hrefForExternal`→`toExternal` composition, the EXT redirect through the real `isValidRedirectURL` guard, the caught callback failure) and `SET_TITLE_LAUNCHPAD` (the deliberately silent absence of `ShellUIService`, a rejecting `setTitle` caught into the log) |
| the action runners in `core/FrontendAction.js` | `actionRunner.spec.js` | that a follow-up action is dispatched as data, and that nothing - not even a JavaScript string an app handed the backend - ever reaches `Function`/`eval` |
| the `eF()` wire itself, BOTH ends: `z2ui5_cl_ui5_srv_event=>escape_js_string` (the real transpiled backend, in a child process) read back as the JavaScript expression it is | `efWireRoundtrip.spec.js` | that an argument arrives as it was sent, for every shape the escaping names — nothing about the wire format is written down in the spec, so it cannot be updated to match a regression. Skips on a tree that was never transpiled |
| the `action( )` entry point of `core/actions/Slots.js` (the VIEW_SLOTS target) | `slotsAction.spec.js` | the argument shapes every slot has to survive - a display without options, the popover anchor, a superseded display; the model fan-out is covered by `view1Events.spec.js`, the display internals only through it |
| `controller/View1.controller.js` event handling (incl. the `eB` busy guard and the one-slot `check_queue_last` queue: last firing kept, dispatched after the response, left to a superseding request, dropped with its controller), the after-render phase (model push by MODEL presence, per-response router sync) and the `core/actions/Slots.js` model fan-out, plus the two event-argument helpers that reach the live control tree (`textPath( )`, and `slotById( )` / `slotValue( )` for a control in another view slot) | `view1Events.spec.js` | `slotValue( )`'s whole point is that it cannot throw — an argument expression is evaluated while UI5 dispatches the handler, so a throw there loses the event and not just the value; four of its five cases are miss paths |
| `core/Server.js` timeout handling | `serverTimeout.spec.js` | — |
| `core/Server.js` request sequencing, the value-aware clear of a winning request's sent paths (`_clearSentPaths`) and the queued-event drop on `reset( )` / `responseError` | `serverRequestSeq.spec.js` | — |
| `core/Server.js` session-constant location cadence | `serverLocation.spec.js` | — |
| `core/Server.js` error routing outside the inner handlers (`readHttp`'s outer catch, `showRenderError`) | `serverRenderError.spec.js` | — |
| `core/Session.js` | `session.spec.js` | — |
| `core/ScrollFocus.js` focus-info capture | `focusInfo.spec.js` | — |
| `core/ScrollFocus.js` UI5-element resolution | `scrollFocus.spec.js` | incl. the pre-1.106 fallback for scroll/focus capture |
| `model/formatter.js` | `formatter.spec.js` | — |
| `model/models.js` device-model wiring | `deviceModel.spec.js` | — |
| `core/Lib.js` event-argument normalization | `eventArgs.spec.js` | — |
| `cc/Storage.js` | `storage.spec.js` | — |
| the public date helpers of `model/formatter.js` | `formatterDates.spec.js` | — |

## The rules that go with them

Those are in `AGENTS.md`, "Testing": the unit-test metadata flag in the
`.clas.xml`, the ban on skipping a test with `sy-sysid`, the `LOCAL FRIENDS`
requirement, and the rule that every `FOR TESTING` method asserts something.
