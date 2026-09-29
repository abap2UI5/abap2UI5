# @abap2ui5/bsp

A UI5 app as an abapGit BSP, and back. Test an app with `ui5 serve`, turn it
into a BSP, push it to git and pull it into an ABAP system with
[abapGit](https://abapgit.org) - no deployment service, no transport of
its own, the app versioned in git like the ABAP around it. And the other way:
a BSP that abapGit serialized, as an app folder again.

No dependencies, Node 18 or later. The same code builds the BSP of
[abap2UI5](https://github.com/abap2UI5/abap2UI5)'s own frontend.

```bash
npx @abap2ui5/bsp app2bsp webapp --name ZMYAPP      # webapp/ -> bsp/.abapgit.xml + bsp/src/
npx @abap2ui5/bsp check bsp                         # the page rules
npx @abap2ui5/bsp bsp2app bsp/src --out webapp2     # and back
```

## app2bsp

```bash
npx @abap2ui5/bsp app2bsp [webapp] --name ZMYAPP [--out bsp] [--text "My app"] [--package-text "..."]
```

Writes an abapGit repository into `--out` (default `bsp`): `.abapgit.xml`
(only when it is not there yet) and `src/` with

| File | |
|---|---|
| `zmyapp.wapa.xml` | the BSP `ZMYAPP` and its page directory - every file of the app is registered as a page |
| `zmyapp.wapa.<path>` | one per file, in the format abapGit reads: lines space-padded to 255 characters |
| `zmyapp.wapa.ui5repositorypathmapping.xml` | the UI5 repository's path mapping, as its upload writes it |
| `zmyapp          <hash>.sicf.xml` | the ICF nodes `/sap/bc/bsp/sap/zmyapp` and `/sap/bc/ui5_ui5/sap/zmyapp` |
| `package.devc.xml` | the package's description |

Then: push the folder to a git repository, create it in abapGit (online, or
offline from a ZIP) in a package of your own, pull, activate the two ICF
nodes in `SICF`, and open `/sap/bc/ui5_ui5/sap/zmyapp/index.html`.

A second run replaces `src/` - as long as it holds only what an earlier run
wrote for that BSP; a file of anybody else's in there stops it.

**Refused, with every case named:** what would not survive the way into the
system, before anything is written.

- A file name with a character other than letters, digits, `_`, `.` and `/`.
  The system rejects the page, and abapGit then the whole BSP -
  `Component-preload.js` is the common case.
- Two files that end up as one page file (`Component.js` and `component.js`).
- A binary file - a page is text.
- A line over 255 characters. The system cuts it into chunks and serves them
  back with newlines in between, which breaks a JavaScript token, a JSON
  string or an XML attribute. Minified code is the common case.

### From a UI5 CLI project

The app folder is `webapp/`, or - when the app takes resources from npm, a
custom control with `includeDependency`, say - the output of a build without
the two steps whose files a BSP cannot hold (the preload bundle, and the
minified copies with their `-dbg` twins):

```bash
npx ui5 build --clean-dest --exclude-task=minify generateComponentPreload
npx @abap2ui5/bsp app2bsp dist --name ZMYAPP
```

Without a preload bundle UI5 loads the app's modules one by one - a few
requests more on the first start of an app of a few files.

## bsp2app

```bash
npx @abap2ui5/bsp bsp2app [folder] [--out webapp] [--name ZMYAPP] [--keep-mapping] [--force]
```

Reads the BSP in `folder` (default `src`) - what abapGit serialized from a
system, or what `app2bsp` wrote - and writes every registered page into
`--out` (default `webapp`) under its own path. `--name` picks the BSP when the
folder holds more than one; the path mapping describes the BSP rather than the
app and is left out unless `--keep-mapping`. `--out` has to be empty unless
`--force`; nothing in it is deleted either way.

The pages come back as the system stores them, which is not quite what went
in: no spaces at the end of a line (they are the padding's), one newline at
the end of every file, and a line that was ever cut at 255 characters stays
cut. `app2bsp` over the result gives the same BSP again, byte for byte.

## check

```bash
npx @abap2ui5/bsp check [folder]
```

Every BSP in `folder` (default `.`) and below: page names the system accepts,
no line over 255 characters, every page file registered, every `.js` page
valid JavaScript as stored.

## API

```js
import { app2bsp, bsp2app, checkBsps } from "@abap2ui5/bsp";

app2bsp({ webapp: "webapp", target: "bsp/src", name: "ZMYAPP", text: "My app", packageText: "My app" });
bsp2app({ source: "bsp/src", target: "webapp2" });
checkBsps("bsp"); // [{ folder, bsps, pages, problems }]
```

`app2bsp` also takes `icfText` (the ICF nodes' description), `mapping`
(`false` for none, or a mapping page of your own) and `sicf: false`.

## Not supported (yet)

- Names in a `/NS/` namespace - their ICF nodes sit below the namespace, and
  the namespace node has to come with them.
- Binary files: images, fonts.

## License

MIT
