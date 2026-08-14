// Fingerprint over the frontend sources, used by trans2abap.js to stamp the
// build identity into app/webapp/core/Build.js and z2ui5_cl_ui5f_build.
//
// Its whole job is to answer one question in two places at once: is the
// frontend running in the browser the frontend this backend embeds? That only
// works if the SAME sources produce the SAME fingerprint everywhere - on a
// developer machine, on a CI runner, and in whatever checkout a downstream
// installation pulled. Two rules follow from that, and both were learned the
// hard way when check_app2abap failed on a tree that was perfectly in sync:
//
//  1. Hash the sources AS THEY SHIP, not the bytes on disk. trans2abap drops
//     trailing whitespace from every line, so two checkouts differing only in
//     line endings or trailing blanks generate byte-identical artefacts. If
//     those got different fingerprints, the check would report drift against a
//     frontend that is in fact the right one - the exact false alarm the whole
//     mechanism exists to avoid.
//
//  2. Sort by code unit, never with localeCompare. Collation depends on the
//     ICU data the running node was built with, which is precisely the kind of
//     thing that differs between a laptop and a runner.
//
// Kept in its own module so both rules can be tested directly - see
// node/tests/fingerprint.spec.js.
const crypto = require('crypto');

// The normalization trans2abap's formatAsAbapClass applies per line, so the
// fingerprint sees what the generated artefact will contain.
function normalizeForHash(text) {
    return text
        .split('\n')
        .map(line => line.replace(/\s+$/, ''))
        .join('\n');
}

// `entries` is [{ relPath, content }]. The path goes into the digest next to
// the content, so a pure rename counts as a change; the content length between
// them keeps the stream unambiguous, without it moving characters from one
// file's tail into the next file's name would hash the same.
function computeFingerprint(entries, length) {
    const digest = crypto.createHash('sha256');
    const sorted = [...entries].sort((a, b) =>
        a.relPath < b.relPath ? -1 : a.relPath > b.relPath ? 1 : 0,
    );
    for (const { relPath, content } of sorted) {
        const normalized = normalizeForHash(content);
        digest.update(`${relPath}\n${normalized.length}\n${normalized}`);
    }
    return digest.digest('hex').slice(0, length);
}

module.exports = { normalizeForHash, computeFingerprint };
