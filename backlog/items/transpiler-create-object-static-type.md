---
target: abaplint
title: '`CREATE OBJECT ref TYPE (name)` does not check the static type of the target, so a wrong class is assigned and the CATCH never runs'
summary: 'the dynamic branch checks only that the name resolves to a class; whatever it resolves to is assigned to the reference, and the mismatch surfaces later as a raw javascript TypeError - which no CATCH takes, where a system raises a catchable CX_SY_CREATE_OBJECT_ERROR'
priority: high
state: open
first_seen: 2026-09-16
checked_upstream: 2026-09-16
patch: backlog/patches/transpiler-create-object-static-type.patch
upstream: abaplint/transpiler
evidence:
  - 'packages/transpiler/src/statements/create_object.ts, the `if (dynamic)` branch: it emits `if (id === undefined) { throw new CX_SY_CREATE_OBJECT_ERROR; }` for a name that resolves to nothing and then `target.set(await (new id()).constructor_())` - there is no test against the static type of `target`'
  - 'reachable from OUTSIDE in abap2UI5: z2ui5_cl_ui5_action=>factory_first_start does `CREATE OBJECT li_app TYPE (app_start)` into a `REF TO z2ui5_if_app`, and `app_start` is the URL parameter. A name pointing at a real class that is not an app (`?app_start=CL_ABAP_TYPEDESCR`) answered with an uncaught TypeError - no body, no status code, none of the security headers - although the statement sits between `CATCH cx_sy_create_object_error` and `CATCH cx_root`'
  - 'the runtime already has the predicate: packages/runtime/src/statements/cast.ts uses `instanceof` for a class target and the IMPLEMENTED_INTERFACES list for an interface target'
  - 'measured with the change on: the transpiler suite is 2229 passing / 0 failing (database legs excluded, they need postgres) and eslint clean; abap2UI5 re-transpiled against it answers all five hostile app_start values with a clean 500 and its own suite stays green (1271 tests)'
---

# A dynamic CREATE OBJECT that ignores the reference it creates into

```abap
DATA li_app TYPE REF TO z2ui5_if_app.
CREATE OBJECT li_app TYPE (lv_name).
```

A system raises `CX_SY_CREATE_OBJECT_ERROR` when `lv_name` names a class that
is not compatible with the static type of `li_app`, and it raises it **before
the constructor runs**. The transpiler checks only that the name resolves to a
class at all. Whatever it resolves to is assigned, and the mismatch shows up on
the first member access as

```
TypeError: Cannot read properties of undefined (reading 'set')
```

which is not an ABAP exception, so neither `CATCH cx_sy_create_object_error`
nor `CATCH cx_root` sees it.

## Why it is worth the `high`

This is the statement a framework uses to start a class the CLIENT named. In
abap2UI5 the name is the `?app_start=` URL parameter, the statement sits in a
`TRY` with both of the above `CATCH` blocks, and the documented behaviour - a
500 whose body says which app could not be started - holds on a system and not
on the transpiled backend, where the whole request died with nothing in it.

The repository's own design note states the bound this breaks: the app-start
dispatch is *"constrained only to classes implementing `z2ui5_if_app`"*. On a
system the typed reference is what enforces that. Transpiled, it enforced
nothing - so the constraint the design argument rests on was not testable in
the one runtime the test suite runs on.

## Current behaviour

`packages/transpiler/src/statements/create_object.ts`:

```ts
ret += `if (${id} === undefined) { throw new ${cx}; }\n`;
clas = id;
...
ret += target + ".set(await (new " + clas + "()).constructor_(" + para + "));";
```

`findClassName( )` already resolves the target's static type for the STATIC
path (and answers `"object"` for a generic reference) - the dynamic path
simply never asks.

## Proposed change

Emit a check between the two, against the class rather than against an
instance, so the constructor does not run first:

```ts
abap.statements.checkCreateObjectType(<resolved>, <static type>, "<NAME>");
```

and the predicate in the runtime is the one `cast.ts` already applies:
`instanceof` for a class target, the `IMPLEMENTED_INTERFACES` list for an
interface target. A `REF TO object` target has nothing to check against and
emits no check at all, so every existing dynamic test - all of which use a
generic reference - is untouched.

Written, tested and measured; the change is attached as
[`backlog/patches/transpiler-create-object-static-type.patch`](../patches/transpiler-create-object-static-type.patch)
(`git am` against `abaplint/transpiler`), with three tests: an incompatible
class, a class that does not implement the target interface, and one that
does. It is not open as a pull request because this session has no write
access to the `abaplint` organization (the Claude GitHub App is not installed
there).

## What abap2UI5 does until then

Nothing, and deliberately. On a system the framework is already correct - the
two `CATCH` blocks in `factory_first_start` do their job - so there is nothing
to repair here, and re-implementing the type check in ABAP would duplicate
what the platform enforces and cost an RTTI read on every app cold start. The
cost is the same one the empty-JSON-key item names: the hostile `app_start`
shapes cannot be pinned by a test in this repository until the pinned
toolchain carries the fix, because the test would die in CI and pass on every
system.

## Removing this

Bump `@abaplint/transpiler-cli` (and `@abaplint/runtime`) in `package.json` to
a version that carries the check, add the test that pins a 500 for an
`app_start` naming a non-app class, and delete this item together with its
patch.
