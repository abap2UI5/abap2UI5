---
target: abap2ui5
title: 'Joule Frontend Actions: let an abap2UI5 app offer its events as actions once SAPUI5 has the API'
summary: 'SAP announced that SAPUI5 registers generic actions with Joule by itself (describeUI, describeUIElement, setFields, executeAction) and plans a unified API for an app''s own actions. An abap2UI5 app is a UI5 app at runtime, so the generic ones may work unchanged; the own ones would fit the frontend''s model - the backend names an event, the frontend fires it. Nothing to build until the API is published.'
priority: low
state: open
first_seen: 2026-11-14
upstream: abap2UI5/abap2UI5
evidence:
  - 'SAP Community, "How AI Is Reshaping SAPUI5: From Development to Runtime to Extensibility" (Oliver Graeff, 2026-11): "SAPUI5 provides a unified API for registering custom actions with SAP Joule (planned feature). Generic actions (such as describeUI, describeUIElement, setFields, executeAction) are registered automatically" - read as pasted by the maintainer on 2026-11-14, the linked detail post not read'
  - 'not checked: whether the API is released, in which UI5 version, and whether the generic actions reach controls inside a component the embed control created'
---

# Joule Frontend Actions for abap2UI5 apps

## What SAP announced

Joule can act on the UI of a running application: an application exposes
actions, Joule calls them for a request in natural language. For SAPUI5 the
generic actions are said to be registered automatically, and an API for an
app's own actions is planned.

## Why it could fit

- At runtime an abap2UI5 app is UI5 controls in a view, so what is generic
  for SAPUI5 should see its fields and buttons like any other app's.
- An action of the app's own maps onto what the frontend does anyway: the
  backend registers an event (`client->_event( )`), the frontend posts it.
  A registration in the bundle (`bundle/webapp/core/`) could offer the
  events of the current view as actions, with the backend deciding which -
  data, not code, as rule 19 asks.

## What to find out first

1. Is the API released, and from which UI5 version on - it would be a lazy
   `sap.ui.require` (rule 12), never a dependency.
2. Do the generic actions work on an abap2UI5 page as it is - in the
   launchpad, where Joule lives, and inside the embed control?
3. What an action has to declare (name, description, parameters) and
   whether the backend can supply that per view.

Until 1 is answered there is nothing to build.
