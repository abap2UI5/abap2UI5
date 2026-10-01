/*
 * compress.d.ts - the types of srv/compress.mjs, the `./compress` subpath of
 * @abap2ui5/node-runtime. The JSDoc in compress.mjs is the source.
 */

export interface CompressOptions {
  /** The smallest body compressed, in bytes (default 1024). */
  threshold?: number;
  /** The zlib level (default 6). */
  level?: number;
  /** How many compressed GET pages are kept, one per ETag (default 16). */
  pages?: number;
}

/** An express-style middleware, `(req, res, next) => void`. */
export type Middleware = (req: object, res: object, next: (err?: unknown) => void) => void;

/** Whether an `Accept-Encoding` header allows gzip. No header: no. */
export function acceptsGzip(header: string | string[] | undefined): boolean;

/**
 * The gzip middleware `createApp()` puts in front of the framework - for an
 * express app of your own that mounts `createHandler()`.
 */
export function compress(options?: CompressOptions): Middleware;
