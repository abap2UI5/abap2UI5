/*
 * accelerate.d.ts - the types of srv/accelerate.mjs, the `./accelerate`
 * subpath of @abap2ui5/node-runtime. The JSDoc in accelerate.mjs is the source.
 */

/** The `@abaplint/runtime` version the fast paths were validated against. */
export const RUNTIME_VERSION: string;

export interface AccelerateOptions {
  /** The runtime instance (default `globalThis.abap`, which `output/init.mjs` creates). */
  abap?: object;
  /** Install on a runtime version other than `RUNTIME_VERSION` - for revalidating a new version, not for a host. */
  force?: boolean;
}

/**
 * Install the fast paths on the running ABAP runtime: `LOOP ... WHERE` over a
 * sorted primary key, and `CP`. Idempotent. Returns whether they are
 * installed - `false` on a runtime version they were not validated for.
 */
export function accelerate(options?: AccelerateOptions): boolean;
