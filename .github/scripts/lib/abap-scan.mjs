/*
 * abap-scan — read the ABAP of this checkout and its siblings.
 *
 * Its own module rather than part of `backlog-probe.mjs` for a mechanical
 * reason: the probes import these helpers and the runner imports the probes,
 * so putting them in the runner deadlocks its top-level await. It is also the
 * better shape — a probe depends on "how do I read the corpus", not on the
 * thing that happens to call it.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..', '..');

/* The checkouts a probe may read: this one and its siblings, by the names the
 * repositories carry. A missing one is REPORTED rather than silently treated
 * as "nothing found there" — a probe that answers 0 because a repository is
 * absent would be worse than no probe. */
const SIBLINGS = [
  ['abap2UI5', ROOT],
  ['samples', path.join(ROOT, '..', 'samples')],
  ['samples-controls', path.join(ROOT, '..', 'samples-controls')],
  ['samples-stack', path.join(ROOT, '..', 'samples-stack')],
];

export function roots() {
  const found = [];
  const missing = [];
  for (const [repo, dir] of SIBLINGS) {
    if (fs.existsSync(path.join(dir, 'src'))) found.push({ repo, dir });
    else missing.push(repo);
  }
  return { found, missing };
}

/** Every `.abap` under a checkout's `src/`, as `{repo, rel, abs, text}`. */
export function abapFiles({ repo, dir }) {
  const out = [];
  const walk = (d) => {
    for (const name of fs.readdirSync(d).sort()) {
      const full = path.join(d, name);
      if (fs.statSync(full).isDirectory()) walk(full);
      else if (full.endsWith('.abap')) {
        out.push({
          repo,
          rel: path.relative(dir, full).split(path.sep).join('/'),
          abs: full,
          text: fs.readFileSync(full, 'utf8'),
        });
      }
    }
  };
  walk(path.join(dir, 'src'));
  return out;
}

export const lines = (file) => file.text.split(/\r?\n/);
export const isComment = (line) => /^\s*[*"]/.test(line);
