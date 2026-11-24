---
target: abaplint
title: 'Design: merge the default options into a rule configured as a partial object, or warn about the omitted ones'
summary: 'a rule given as an object takes only the options it names, an omitted boolean option is off - "check_subrc": { "exclude": [...] } is on and checks nothing; four repositories had such a rule the same day, found only by injecting a probe'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/table-maintenance 5ea673e, abap2UI5-addons/custom-controls c454278, abap2UI5-addons/popups e8b7b47, abap2UI5-addons/layout-management c1e6afe (all 2026-11-24): rules written as { "exclude": [...] } were on and checked nothing - check_subrc and avoid_use in table-maintenance, no_dynamic_stuff in custom-controls, sub-options of other rules elsewhere; noticed only when an unchecked READ TABLE injected as a probe did not fire check_subrc. Each repository now spells out every option of `abaplint --default`'
  - 'probed 2026-11-24 against abaplint 2.120.116, open-abap-core as dependency, one class with an unchecked SELECT: "check_subrc": true reports "Check sy-subrc (check_subrc)"; "check_subrc": { "exclude": [] } and { "exclude": [], "severity": "Error" } report nothing'
---

# Design: merge the default options into a rule configured as a partial object, or warn about the omitted ones

```jsonc
"rules": {
  "check_subrc": true,                                   // checks SELECT, READ TABLE, ...
  "check_subrc": { "exclude": ["/src/legacy/.*"] }       // on - and checks nothing at all
}
```

The second form reads as "check_subrc, except in these files". It is "check_subrc
with every option off": no finding, no warning, and the rule shows as
configured. The same happens to any rule whose behaviour sits in boolean
options - `avoid_use`, `no_dynamic_stuff`, `check_subrc`, `empty_structure`,
`unnecessary_pragma` and many more - and to an option added in a later
release, which a configuration written before it never names.

**Current behaviour.** `config.ts`, `getEnabledRules`: for an object,
`rule.setConfig(ruleConfig)` replaces the rule's default configuration object
with the JSON object as it is. A rule then reads `this.conf.<option>`, and an
omitted option is `undefined` - falsy. Only `true` gets the defaults (the
instance keeps its `new XConf()`).

**Proposal.** One of:

1. **merge**: `rule.setConfig({...rule.getConfig(), ...ruleConfig})` - an
   omitted option keeps its default. This changes what existing configurations
   check (they start finding what they were meant to), so it may need a major
   version or a global switch (`"global": { "ruleDefaults": "merge" }`);
2. **warn**: when a rule object omits an option its config class declares,
   report it once per rule (in the existing configuration checks or as a
   CLI warning: "check_subrc: options not set, treated as false: openDataset,
   authorityCheck, selectSingle, ..."). `abaplint --default` already writes
   every option, so a complete configuration stays silent.

The warning alone would have saved the four repositories above; the merge is
what the configuration format suggests to whoever writes it.

**Not reported** (for the warning). An option that is not boolean and has no
effect when unset (`exclude`, `severity`); a rule given as `true` or `false`.

**Where.** `config.ts` (`getEnabledRules`), or a configuration check.
**Effort:** S for the warning, M for the merge (compatibility).

**Source.** Four abap2UI5 addon repositories, one day.

A PR is being prepared from oblomov-dev/fork-abaplint.

Related upstream: abaplint/abaplint#3923 (open - rulesets: "take the default config, override with the rules below", the same remedy proposed as a feature, without naming the silent failure).
