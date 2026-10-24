# App catalog

## The problem

An installation that runs abap2UI5 for a year has dozens of app classes.
The questions an owner of the installation is asked are about them as a
set: which apps exist, who owns each one, which version is in production,
when was it last transported, which launchpad tiles and roles start it, and
which apps nobody uses any more.

Today the answers are in three places. The
[admin cockpit](https://github.com/abap2UI5-addons/admin-cockpit) answers
*is it used, is it fast, is it safely configured* - usage, performance and
errors per app class, the apps nobody has started in N days. The transport
system knows versions and transports. The launchpad content knows tiles and
roles. Nothing puts them on one line per app.

## The first cut

A tab of the admin cockpit - not a new add-on - with one row per class that
implements `z2ui5_if_app`:

| Column | From |
|---|---|
| App, description | the class and its description |
| Package, owner | the package (`TADIR`) and its responsible person; the class's `@owner` ABAP Doc tag when there is one |
| Last change, last transport | the version management of the class (`VRSD`) and the transport that carried it (`E070`/`E071`) |
| Tiles, roles | the launchpad target mappings whose parameters name the class (`app_start=`), and the roles of their catalogs |
| Used | the cockpit's own figures: users and roundtrips in the last 30 days, last use |

Read-only. Every column is something the system already holds; the catalog
reads it and shows it next to the others, and a row links to where each part
is changed - the class in ADT, the transport, the launchpad content manager.

## What it must not become

- **A registry an app has to be entered into.** An app is in the catalog
  because it is a class implementing the interface - nothing to register,
  nothing to forget.
- **A second transport or role tool.** Tiles and roles are maintained where
  they are maintained today; the catalog shows them.
- **Something the framework needs.** It stays an add-on; an installation
  without it loses nothing.

## Next steps

1. The read-only tab as above, in the cockpit.
2. Write a tile: for an app without a tile, create the target mapping and
   the tile in a chosen catalog from the row - the one write that saves the
   most clicks, and the one that needs the most care (the launchpad APIs
   differ between releases and between on-premise and BTP).
3. Export the catalog as a list for an audit: CSV, with the SBOM version of
   the installed framework on top.

## Open questions

- On ABAP Cloud, `TADIR`, `VRSD` and the transport tables are not released;
  which released APIs answer the same questions there?
- Is `@owner` in ABAP Doc a convention worth proposing, or is the package's
  responsible person enough?
