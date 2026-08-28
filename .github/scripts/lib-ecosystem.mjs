#!/usr/bin/env node
/*
 * lib-ecosystem — WHICH repositories the organisation's rules apply to, and how
 * to read a file out of one.
 *
 * It lived inside `scripts-gate.mjs`, which was fine while one gate enumerated
 * the ecosystem. `toolchain-gate.mjs` is the second, and two hand-maintained
 * copies of this list is precisely the drift both gates exist to catch - the
 * `playground` entry took until 2026-08-28 to appear in the first one, and a
 * second list would have started a day behind.
 *
 * `read()` is the comparison order both gates use, and the reason is the one
 * `shared-file-gate.mjs` states: a repository's gates must not go red because
 * github.com is unreachable, and they must not claim to have verified
 * something they did not. So an unreachable repository is a NOTE and a pass,
 * and the caller reports how many it actually checked.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

export /* Every repository in the ecosystem that carries a package.json, this one
 * included - it is subject to its own rule, and reading it from disk rather
 * than exempting it is one line cheaper than the exemption.
 *
 * A list rather than a discovery call: the organisation also holds generated
 * channel repositories (`frontend`, `web-abap2UI5-build`) that have no
 * package.json and no contributor to type a command, and an API listing would
 * pull those in and then need an exclusion list anyway. */
const REPOS = [
  'abap2UI5',
  'samples',
  'samples-controls',
  'samples-stack',
  'app-template',
  'mcp-server',
  'vscode-extension',
  'linter',
  'docs',
  'web-abap2UI5',
  /* Added 2026-08-28. It was missing, and the omission is what the rule is
   * about: `playground` is a source repository with an AGENTS.md, a test
   * suite, its own `check.yml` and a contributor - and it had no `check`
   * script at all, which is precisely the state this gate exists to refuse.
   * Nothing found that, because nothing was looking. */
  'playground',

  /* The addons, which sit in a second organisation and were outside every
   * ecosystem gate until 2026-08-20 - which is how eleven repositories came to
   * disagree with CONVENTIONS on workflow naming, toolchain pins and these two
   * scripts at once, and how one of them shipped for ten days against a class
   * that exists nowhere. They are source repositories with contributors, so
   * the rule is theirs too. */
  { org: 'abap2UI5-addons', repo: 'popups' },
  { org: 'abap2UI5-addons', repo: 'se16n' },
  { org: 'abap2UI5-addons', repo: 'sql-console' },
  { org: 'abap2UI5-addons', repo: 'table-content-loader' },
  { org: 'abap2UI5-addons', repo: 'table-maintenance' },
  { org: 'abap2UI5-addons', repo: 'layout-management' },
  { org: 'abap2UI5-addons', repo: 'selection-screen' },
  { org: 'abap2UI5-addons', repo: 'lock-manager' },
  { org: 'abap2UI5-addons', repo: 'custom-controls' },
  { org: 'abap2UI5-addons', repo: 'rap-ext' },
  { org: 'abap2UI5-addons', repo: 'fork-abapToC' },
].map((e) => (typeof e === 'string' ? { org: 'abap2UI5', repo: e } : e));

const raw = ({ org, repo }, file) => `https://raw.githubusercontent.com/${org}/${repo}/main/${file}`;

/* One file from one repository, as { text, from } - or { missing: true } when
 * the repository was reached and the file is not in it, which is a finding, or
 * { note } when the repository could not be reached at all, which is not.
 *
 * `abap2UI5` is the checkout this runs in rather than a sibling of it. */
export async function read(entry, file) {
  const { repo } = entry;
  const local = repo === 'abap2UI5'
    ? path.join(ROOT, file)
    : path.join(ROOT, '..', repo, file);

  if (fs.existsSync(path.join(ROOT, '..', repo)) || repo === 'abap2UI5') {
    return fs.existsSync(local)
      ? { text: fs.readFileSync(local, 'utf8'), from: 'checkout' }
      : { missing: true, from: 'checkout' };
  }
  try {
    const res = await fetch(raw(entry, file), { signal: AbortSignal.timeout(15000) });
    if (res.status === 404) {
      /* A 404 from raw.githubusercontent.com is two different answers wearing
       * one status code: the file is not in the repository, or the REPOSITORY
       * is not readable — private, renamed, or gone. Reporting the second as
       * the first invents a finding against a repository nobody can even see,
       * and `abap2UI5-addons/lock-manager` is exactly that case: every path
       * probed on it 404s, while its siblings answer 200 for all of them.
       *
       * So ask a sentinel the repository must have if it is visible at all.
       * Only when THAT answers is a 404 on the wanted file a real absence. */
      return (await visible(entry))
        ? { missing: true, from: 'github' }
        : { note: 'repository not readable at raw.githubusercontent.com — private, renamed, or gone' };
    }
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return { text: await res.text(), from: 'github' };
  } catch (err) {
    return { note: err.message };
  }
}

/* Is the repository readable at all? Cached per repository — every caller that
 * gets a 404 asks, and without the cache a repository that is simply gone
 * would be probed once per file checked. */
const visibility = new Map();

async function visible(entry) {
  const key = `${entry.org}/${entry.repo}`;
  if (visibility.has(key)) return visibility.get(key);
  const answer = (async () => {
    /* Two sentinels, because a repository may legitimately lack either one;
     * only if NEITHER answers is the repository itself unreadable. */
    for (const sentinel of ['README.md', '.gitignore']) {
      try {
        const res = await fetch(raw(entry, sentinel), { signal: AbortSignal.timeout(15000) });
        if (res.ok) return true;
      } catch { /* a transport failure here is not evidence either way */ }
    }
    return false;
  })();
  visibility.set(key, answer);
  return answer;
}
