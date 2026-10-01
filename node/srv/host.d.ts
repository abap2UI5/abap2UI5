/*
 * host.d.ts - the types of @abap2ui5/node-runtime's entry point (srv/host.mjs).
 * Hand-written: the package ships JavaScript, and this file is the one place
 * a TypeScript host - or an editor - reads the signatures from. Keep it to
 * what host.mjs exports and documents; the JSDoc there is the source.
 */
import type { Server } from "node:http";

export { accelerate, RUNTIME_VERSION } from "./accelerate.js";
export { compress } from "./compress.js";

/**
 * An express application, 4 or 5 - typed loosely on purpose: `express` is an
 * optional peer, so its types are not a dependency of this package. A host
 * that has `@types/express` narrows the result itself.
 */
export interface ExpressApp {
  use(...handlers: unknown[]): unknown;
  listen(...args: unknown[]): unknown;
  [key: string]: unknown;
}

/** An express-shaped request handler, (req, res) => Promise<void>. */
export type Handler = (req: object, res: object) => Promise<void>;

/** The `if_http_extension` class every request goes to: `"ZCL_SICF"`. */
export const HANDLER_CLASS: string;

export interface HandlerOptions {
  /** Another `if_http_extension` class, transpiled into the same runtime, instead of `ZCL_SICF`. */
  handlerClass?: string;
}

export interface AppOptions extends HandlerOptions {
  /** The raw body parser's limit (default `"10mb"`). */
  bodyLimit?: string;
  /** `false` leaves the gzip out (a proxy in front compresses anyway); an object is `compress()`'s options. */
  compression?: boolean | CompressOptions;
}

export interface ServeOptions extends AppOptions {
  /** The port to listen on (default 3000). */
  port?: number | string;
  /** The host to bind; unset binds every interface, `"127.0.0.1"` loopback only. */
  host?: string;
}

/** `compress()`'s options - see compress.d.ts. */
export interface CompressOptions {
  threshold?: number;
  level?: number;
  pages?: number;
}

/**
 * Boot the ABAP runtime once - the SQLite database, the schema, the
 * framework - and install `accelerate()`'s fast paths. Every call returns the
 * first call's promise.
 */
export function initialize(): Promise<void>;

/**
 * The HTTP handler alone, for a server that is not express. It reads an
 * express-shaped request (`method`, `url`, `path`, `headers`, `body` as a
 * Buffer) and response (`append()`, `status().send()`), and boots the
 * runtime on the first request when nothing called `initialize()` before.
 */
export function createHandler(options?: HandlerOptions): Handler;

/**
 * An express app (4 or 5) that serves the framework on every path: `compress()`,
 * the raw body parser and the handler. Mount it under a path of your own app.
 */
export function createApp(options?: AppOptions): Promise<ExpressApp>;

/**
 * Boot the runtime, then listen. Resolves with the server once the framework
 * can answer; rejects on a port that is taken.
 */
export function serve(options?: ServeOptions): Promise<Server>;
