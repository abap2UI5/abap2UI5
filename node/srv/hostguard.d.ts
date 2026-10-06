/*
 * hostguard.d.ts - the types of srv/hostguard.mjs, re-exported by the entry
 * point. The JSDoc in hostguard.mjs is the source.
 */

export interface HostGuardOptions {
  /** The address the server binds - allowed as a name unless it is a wildcard (0.0.0.0, ::). */
  host?: string;
  /** More host names to answer, comma-separated or a list; `"*"` answers any. */
  allowedHosts?: string | string[];
}

/** The names a request may address, or `null` when any is allowed. */
export function allowedHostNames(options?: HostGuardOptions): Set<string> | null;

/** Whether a request with these headers is answered (Host, and Origin when present). */
export function requestAllowed(
  headers: Record<string, string | string[] | undefined>,
  allowed: Set<string> | null,
): boolean;

/**
 * The guard `serve()` puts in front of the framework, as an express-style
 * middleware: a refused request gets a 403, every other goes on to `next`.
 */
export function hostGuard(
  options?: HostGuardOptions,
): (req: object, res: object, next: () => void) => void;
