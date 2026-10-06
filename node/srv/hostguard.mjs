/*
 * hostguard.mjs - which requests serve() answers: those addressed to this
 * machine by a name it was meant to be reached by, and - when they carry an
 * Origin - coming from a page on such a name.
 *
 * WHY. serve() (and with it `npm run express`, the dev server) used to answer
 * any Host and any Origin. Binding loopback is not enough on its own: a web
 * page the developer opens in any browser on the same machine reaches
 * 127.0.0.1 too. It can post to the port blind, and through DNS rebinding -
 * a name of the page's own that resolves to 127.0.0.1 a moment later - it
 * reads the answers as well: a same-origin page then, with the apps, their
 * events and their data at its disposal. Both carry a Host (the rebinding
 * name) or an Origin (the attacking page) that is not this machine's, which
 * is what the guard looks at. abap2UI5/mcp-server's npm host has guarded
 * its own server the same way since its lib/npm-host.mjs.
 *
 * THE RULE. A request passes when
 *   - its Host, without the port, is one of the allowed names, and
 *   - it carries no Origin, or an http(s) Origin whose host name is one of
 *     them (`Origin: null` - a sandboxed frame, a file: page - is refused).
 * The allowed names are 127.0.0.1, localhost and [::1], plus
 *   - the address serve() was told to bind, when that is a name of its own
 *     (HOST=192.168.1.5, HOST=devbox.lan): binding it deliberately is asking
 *     to be reached by it. Not 0.0.0.0 / :: - those name no host;
 *   - every name in `allowedHosts` (express.mjs: the ALLOWED_HOSTS
 *     environment variable, comma-separated) - for a container reached by its
 *     service name, a LAN address on an all-interfaces bind, a proxy.
 * `allowedHosts` "*" switches the guard off: any Host, any Origin, the old
 * behaviour - for a server behind something that decides this itself.
 *
 * WHAT IT DOES NOT CHANGE. createApp() and createHandler() stay unguarded: a
 * host that mounts them owns its server, its names and its exposure (cap2UI5
 * mounts the handler into CAP). It can put hostGuard() in front itself.
 */

const LOOPBACK_NAMES = ["127.0.0.1", "localhost", "[::1]"];

// binds that name no host a request could address
const WILDCARD_BINDS = new Set(["", "0.0.0.0", "::", "[::]"]);

/**
 * A host name as a Host header and URL.hostname spell it: lower case, an
 * IPv6 address in brackets, no port.
 * @param {unknown} value
 * @returns {string}
 */
function hostName(value) {
  const name = String(value ?? "").trim().toLowerCase();
  if (!name) return "";
  if (name.startsWith("[")) {
    const end = name.indexOf("]");
    return end > 0 ? name.slice(0, end + 1) : name;
  }
  // a bare IPv6 address has more than one colon; a name or IPv4 has at most
  // the one before the port
  if ((name.match(/:/g) || []).length > 1) return `[${name}]`;
  return name.replace(/:\d*$/, "");
}

/**
 * The names a request may address, or `null` when any is allowed.
 * @param {{ host?: string, allowedHosts?: string | string[] }} [options]
 * @returns {Set<string> | null}
 */
export function allowedHostNames({ host, allowedHosts } = {}) {
  const extra = (Array.isArray(allowedHosts) ? allowedHosts : String(allowedHosts ?? "").split(","))
    .map((entry) => String(entry).trim())
    .filter(Boolean);
  if (extra.includes("*")) return null;
  const names = new Set(LOOPBACK_NAMES);
  const bound = hostName(host);
  if (!WILDCARD_BINDS.has(bound)) names.add(bound);
  for (const entry of extra) names.add(hostName(entry));
  return names;
}

/**
 * Whether a request with these headers is one to answer.
 * @param {Record<string, string | string[] | undefined>} headers
 * @param {Set<string> | null} allowed what allowedHostNames() answered
 * @returns {boolean}
 */
export function requestAllowed(headers, allowed) {
  if (allowed === null) return true;
  const host = hostName(headers?.host);
  if (!allowed.has(host)) return false;
  const origin = headers?.origin;
  if (origin === undefined) return true;
  try {
    const url = new URL(String(origin));
    return (url.protocol === "http:" || url.protocol === "https:") && allowed.has(hostName(url.hostname));
  } catch {
    return false; // "null", or no URL at all
  }
}

/**
 * The guard as an express-style middleware: a request it refuses gets a 403
 * that names the switch, every other one goes on to `next`.
 * @param {{ host?: string, allowedHosts?: string | string[] }} [options]
 * @returns {(req: any, res: any, next: () => void) => void}
 */
export function hostGuard(options = {}) {
  const allowed = allowedHostNames(options);
  return function guard(req, res, next) {
    if (requestAllowed(req.headers, allowed)) {
      next();
      return;
    }
    res.writeHead(403, { "content-type": "text/plain; charset=utf-8" });
    res.end(
      "abap2UI5: this server answers requests addressed to " +
        [...(allowed ?? [])].join(", ") +
        ", from a page there. To serve another name, list it in allowedHosts" +
        " (npm run express: ALLOWED_HOSTS=<name>,<name>, or * for any).\n",
    );
  };
}
