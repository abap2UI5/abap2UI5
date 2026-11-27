---
target: abaplint
title: 'rename: a file outside the folder of the configuration is written outside rename.output since 2.120.122'
summary: 'with the configuration in .github/abaplint and files "/../../src/**", --rename of 2.120.122 writes to <output>/../../src/..., which is outside the output folder; 2.120.121 wrote below it - two addons stay on 2.120.121 because of it'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4813
first_seen: 2026-11-27
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/layout-management 2a91e97 and table-maintenance 1ac9421, 2026-11: both keep @abaplint/cli at 2.120.121 - "Not 2.120.122: its --rename writes the result to another folder, which the rename check does not find"; the shared .github/scripts/rename.mjs has its configuration in .github/abaplint, files /../../src/** and output "output"'
  - 'probed 2026-11-27 against abaplint main after 2.120.122: configuration in cfg/lint, files /../../src - the log says Write cfg/lint/output/../../src/zif_x_ren.intf.abap, the file lands in cfg/src/ and output/ stays empty; 2.120.113 wrote cfg/lint/output/<absolute path>/src/...'
  - 'packages/cli/src/rename.ts write( ): the name is outputFolder + path.relative( base, filename ) since abaplint/abaplint#4795 (output folder on Windows), which is ../../src/... for a file above the base; the test #4795 added covers files below the base only'
  - 'upstream search 2026-11-27 (open issues and pull requests of abaplint/abaplint): nothing on it; filed the same day as abaplint/abaplint#4813 - the leading .. segments of the relative path are dropped, so a file above the base is written to <output>/src/...'
---

# rename: a file above the base folder leaves `rename.output`

A repository that keeps its abaplint configuration in a sub folder points at
its sources with a relative path:

```jsonc
// .github/abaplint/rename.jsonc
"global": { "files": "/../../src/**/*.*" },
"rename": { "output": "output", "patterns": [ ... ] }
```

Up to 2.120.121 the renamed files were written below `output/`. Since
2.120.122 (#4795) the name is `output/` plus the path of the file relative to
the base, and for a file above the base that path starts with `../..` - the
file is written next to the sources instead of into the output folder, and
`output/` stays empty.

## Proposal

Keep every written file below the output folder: take the path relative to
the common root of all files, or drop the leading `..` segments.

## Must not change

The layout for files below the base, and the Windows case #4795 was made for
(the drive letter in another case, the long-path prefix).
