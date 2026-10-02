/*
 * accelerate.d.ts - the types of srv/accelerate.mjs, the `./accelerate`
 * subpath of @abap2ui5/node-runtime. The JSDoc in accelerate.mjs is the source.
 */

/** The first `@abaplint/runtime` version whose `LOOP ... WHERE` and `CP` are linear. */
export const RUNTIME_VERSION: string;

export interface AccelerateOptions {
  /** The runtime instance (default `globalThis.abap`, which `output/init.mjs` creates). */
  abap?: object;
  /** Accepted and ignored: there is nothing left to install. */
  force?: boolean;
}

/**
 * Report whether the running ABAP runtime is linear on large tables. Installs
 * nothing - `@abaplint/runtime` from `RUNTIME_VERSION` on has the fast
 * `LOOP ... WHERE` over a sorted primary key and `CP` itself. Returns `false`,
 * and warns once, on an older runtime.
 */
export function accelerate(options?: AccelerateOptions): boolean;
