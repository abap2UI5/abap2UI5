<!--
  The metadata convention the three app repositories share, and the SOURCE of
  it. It is not a rule about the framework — abap2UI5 ships no `meta/` sidecar
  and no `@keywords` — but a shared file needs one owner, and this is the
  repository the other three already depend on. Same reasoning as
  `.github/abaplint/app-rules.json`, which is here for the same reason.

  Consumers carry it inside their own `AGENTS.md`, because that is the file an
  agent reads; nothing here asks them to link out to it. A consumer may ADD its
  own `###` subsection after the shared ones (samples-controls documents its
  generators that way) — declared in `shared-file-gate.mjs` and dropped before
  the comparison. Everything else must match this file, section for section.

  Changing the convention means changing THIS file first, then the copies.
  `npm run check:shared` is what notices when that did not happen.
-->

## Metadata: what goes on the class, and what goes beside it

Shared across `abap2UI5/samples`, `abap2UI5/samples-controls` and
`abap2UI5/samples-stack`. Decided once, so nobody has to decide it again per
repository.

**A class says what it IS. A sidecar records what HAPPENED to it.**

| | where | why |
|---|---|---|
| `DESCRIPT` — `Titel - Kurzbeschreibung` | `.clas.xml` | 60 characters, hard. What ADT's object list shows |
| `" @summary` — one sentence | first lines of `.clas.abap` | no limit. The line a catalogue puts under the title |
| `" @keywords` — search terms | first lines of `.clas.abap` | what somebody would type who does not know the sample exists |
| upstream sample, port batch, audit findings, verification date, deviations | a sidecar (`meta/<class>.json`) | not properties of the class; written by machinery; long-form; changes on a different schedule |

### Why the first three are not in a sidecar

**A sidecar does not travel.** abapGit pulls `src/`; a `meta/` folder never
reaches the SAP system. Three places that costs:

1. **In the system it is simply absent** — which is why an overview app that
   needs the data has to have it *baked in* by a generator.
2. **A search engine drops somebody into the `.clas.abap` on GitHub** and the
   code is all they get. This is the same argument `@docs` is a full URL for.
3. **An AI reading the class file gets no metadata** unless its tooling happens
   to know about `meta/`.

A `"` comment costs the ABAP nothing — it is not `"!`, so SLIN/ATC does not
report an unknown tag — and it cannot desync from the class, because it is in
the class.

### Why the rest is not on the class

A deviation note with three paragraphs and a verification date is not a
property of the class; it is a log entry about a process, usually written by a
test run rather than by an author. Putting it in a `"` comment would bloat the
source and would still be worse structured than JSON. That belongs beside the
class, and the sidecar is right for it.

### The test, when a new field turns up

Ask: *would this still be true if nobody ever ran a check again?* If yes it
describes the sample and belongs on the class. If it only became true because
somebody did something, it belongs in the sidecar.
