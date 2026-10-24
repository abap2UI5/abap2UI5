# Concepts

Designs for things abap2UI5 does not do yet: what each would be, the first
cut that is worth building, what it must not become, and the questions that
decide whether it is built at all. A concept is a proposal for the
maintainers, not a promise and not a plan with dates; it is deleted when its
first cut ships (the details then live in the code, the changelog and the
documentation) or when it is decided against (the reason then goes to
[decisions.md](../agents/decisions.md), so it is not proposed again).

Every concept keeps the one sentence the framework is built on: **an app is
an ABAP class.** A feature that needs a second place where an app is defined
- a model in a database, a flow in a designer that is not code - is not one
of these.

| Concept | In one sentence | State |
|---|---|---|
| [Offline queue](offline.md) | Events an app names wait in the browser while the network is gone and are sent in order when it is back | first cut on a branch: `cs_event-offline_queue`, experimental |
| [Visual builder, both ways](visual-builder.md) | Build a view by clicking, and click through a view that was written by hand - the class stays the source | proposal |
| [App catalog](app-catalog.md) | Every app of an installation with its owner, version, transport and tiles, as an app | proposal |
| [Approvals](approvals.md) | A small add-on for the status-and-inbox kind of workflow most apps need | proposal |
| [Packaged mobile app](mobile-app.md) | From the mobile shell's proof of concept to an app an organization can roll out | proposal |
| [From description to class](ai-package.md) | One path from a sentence to a reviewed, tested class, with the tools that already exist | proposal |
