# Approvals

## The problem

Many of the apps that get built with abap2UI5 end in the same few steps:
somebody enters something, somebody else approves or rejects it, the first
person is told. A purchase request, a master-data change, a price
exception. Each app builds these steps again - a status field, a list of
what waits for me, a mail - or the requirement goes to a workflow tool, and
the app is split in two.

SAP's own workflow (SAP Business Workflow, flexible workflow, SAP Build
Process Automation) covers the large cases and should be used for them. The
gap is the small case: two or three steps, one approver, no designer, in
the same class as the screen.

## The first cut

An add-on in abap2UI5-addons, `approvals`:

- **One table** (all names here provisional), `zappr`: object type and key
  (what is approved), step, status (`open`, `approved`, `rejected`, `withdrawn`), requester, approver,
  timestamps, a comment. One row per step; the history is the rows.
- **One class to call from an app**:

  ```abap
  DATA(request) = zcl_appr=>request( object = `ZPURCHASE`
                                     key    = ms_head-id
                                     to     = lv_approver
                                     text   = |Purchase { ms_head-id }| ).
  ```

  and `zcl_appr=>decide( id = ... approve = abap_true comment = ... )`,
  `zcl_appr=>status( object = ... key = ... )`. The app decides who
  approves - from its own data, an org unit, a table - and what happens on
  approval; the add-on keeps the record.
- **One inbox app**, `zcl_appr_inbox`: what waits for me, with approve
  and reject, and a link into the app that made the request (its class, with
  the key as a start parameter). A launchpad tile with the count.
- **Notification** through what the system already sends: mail via
  `cl_bcs` (on-premise) or the released mail API (ABAP Cloud), optionally the
  launchpad's notification channel.

## What it must not become

- **A process designer.** No graphical flow, no rules engine. A second step
  is a second call from the app's own code, where the condition for it is.
- **A replacement for SAP's workflow.** Substitution rules, deadlines with
  escalation, parallel approvals across systems - those cases go to the
  workflow tools that exist for them, and the add-on's documentation says so.
- **Authorization by the add-on.** Who may approve is the app's check, like
  every authorization in abap2UI5; the add-on records who did.

## Next steps

1. The table, the class and the inbox, on-premise first, with abapGit.
2. ABAP Cloud: the released mail API and a released number range.
3. A sample in abap2UI5/samples: a purchase request from entry to approval.

## Open questions

- Substitution (an approver on holiday): out of the first cut, but is a
  simple "forward to" enough for the add-on, or does it pull the whole topic
  in?
- Should the inbox show SAP workflow items too (`SAP_WAPI_*`), so a user has
  one list? It would make the add-on depend on the workflow runtime.
