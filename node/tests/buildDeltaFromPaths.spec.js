// @ts-check
const { test, expect } = require('@playwright/test');

// Extract the pure function from the controller for unit testing
function _buildDeltaFromPaths(paths, xx) {
    let delta = {};
    for (let path of paths) {
        let parts = path.substring(4).split('/');
        let attr = parts[0];
        if (parts.length >= 3 && !isNaN(parts[1])) {
            if (!delta[attr] || !delta[attr]["__delta"]) {
                delta[attr] = { "__delta": {} };
            }
            let rowIdx = parts[1];
            if (!delta[attr]["__delta"][rowIdx]) {
                delta[attr]["__delta"][rowIdx] = {};
            }
            delta[attr]["__delta"][rowIdx][parts[2]] = xx[attr]?.[parseInt(rowIdx)]?.[parts[2]];
        } else {
            delta[attr] = xx[attr];
        }
    }
    return delta;
}

// ── Test data ───────────────────────────────────────────────────────────
const SAMPLE_XX = {
    NAME:   "Max Mustermann",
    STATUS: "ACTIVE",
    COUNT:  42,
    TABLE1: [
        { COL1: "A1", COL2: "B1", COL3: "C1" },
        { COL1: "A2", COL2: "B2", COL3: "C2" },
        { COL1: "A3", COL2: "B3", COL3: "C3" },
    ],
    TABLE2: [
        { FIELD: "X", VALUE: "100" },
        { FIELD: "Y", VALUE: "200" },
    ],
};

// ── 1. Simple properties ────────────────────────────────────────────────
test.describe('Simple property changes', () => {

    test('single scalar property', () => {
        const paths = new Set(['/XX/NAME']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({ NAME: "Max Mustermann" });
    });

    test('multiple scalar properties', () => {
        const paths = new Set(['/XX/NAME', '/XX/STATUS']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            NAME:   "Max Mustermann",
            STATUS: "ACTIVE",
        });
    });

    test('numeric scalar property', () => {
        const paths = new Set(['/XX/COUNT']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({ COUNT: 42 });
    });
});

// ── 2. Table cell edits (delta) ─────────────────────────────────────────
test.describe('Table cell edits → __delta', () => {

    test('single cell edit', () => {
        const paths = new Set(['/XX/TABLE1/0/COL1']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: { "0": { COL1: "A1" } } }
        });
    });

    test('multiple cells in same row', () => {
        const paths = new Set(['/XX/TABLE1/1/COL1', '/XX/TABLE1/1/COL2']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: { "1": { COL1: "A2", COL2: "B2" } } }
        });
    });

    test('cells in different rows', () => {
        const paths = new Set(['/XX/TABLE1/0/COL1', '/XX/TABLE1/2/COL3']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: {
                "0": { COL1: "A1" },
                "2": { COL3: "C3" },
            } }
        });
    });

    test('cells in different tables', () => {
        const paths = new Set(['/XX/TABLE1/0/COL1', '/XX/TABLE2/1/VALUE']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: { "0": { COL1: "A1" } } },
            TABLE2: { __delta: { "1": { VALUE: "200" } } },
        });
    });

    test('all cells in every row of a table', () => {
        const paths = new Set([
            '/XX/TABLE1/0/COL1', '/XX/TABLE1/0/COL2', '/XX/TABLE1/0/COL3',
            '/XX/TABLE1/1/COL1', '/XX/TABLE1/1/COL2', '/XX/TABLE1/1/COL3',
            '/XX/TABLE1/2/COL1', '/XX/TABLE1/2/COL2', '/XX/TABLE1/2/COL3',
        ]);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: {
                "0": { COL1: "A1", COL2: "B1", COL3: "C1" },
                "1": { COL1: "A2", COL2: "B2", COL3: "C2" },
                "2": { COL1: "A3", COL2: "B3", COL3: "C3" },
            } }
        });
    });
});

// ── 3. Mixed: scalars + table cells ─────────────────────────────────────
test.describe('Mixed changes (scalar + table)', () => {

    test('scalar and table cell together', () => {
        const paths = new Set(['/XX/NAME', '/XX/TABLE1/2/COL2']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            NAME: "Max Mustermann",
            TABLE1: { __delta: { "2": { COL2: "B3" } } },
        });
    });

    test('multiple scalars and multiple table cells', () => {
        const paths = new Set([
            '/XX/NAME', '/XX/STATUS',
            '/XX/TABLE1/0/COL1', '/XX/TABLE2/1/FIELD',
        ]);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            NAME:   "Max Mustermann",
            STATUS: "ACTIVE",
            TABLE1: { __delta: { "0": { COL1: "A1" } } },
            TABLE2: { __delta: { "1": { FIELD: "Y" } } },
        });
    });
});

// ── 4. Fallback: whole table / row-level paths ──────────────────────────
test.describe('Fallback paths → full value', () => {

    test('whole table path sends full array', () => {
        // e.g. model.setProperty("/XX/TABLE1", newArray)
        const paths = new Set(['/XX/TABLE1']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({ TABLE1: SAMPLE_XX.TABLE1 });
    });

    test('row-level path (2 parts) sends full array', () => {
        // e.g. model.setProperty("/XX/TABLE1/0", newRow)
        const paths = new Set(['/XX/TABLE1/0']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({ TABLE1: SAMPLE_XX.TABLE1 });
    });

    test('non-numeric index treated as simple property', () => {
        // e.g. "/XX/TABLE1/abc" → parts = ["TABLE1","abc"], isNaN("abc") = true → else
        const paths = new Set(['/XX/TABLE1/abc']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({ TABLE1: SAMPLE_XX.TABLE1 });
    });
});

// ── 5. Edge cases ───────────────────────────────────────────────────────
test.describe('Edge cases', () => {

    test('empty paths set returns empty delta', () => {
        const paths = new Set();
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({});
    });

    test('missing attribute in XX returns undefined', () => {
        const paths = new Set(['/XX/NONEXISTENT']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({ NONEXISTENT: undefined });
    });

    test('out-of-bounds row index returns undefined cell value', () => {
        const paths = new Set(['/XX/TABLE1/99/COL1']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: { "99": { COL1: undefined } } }
        });
    });

    test('missing column name returns undefined cell value', () => {
        const paths = new Set(['/XX/TABLE1/0/NONEXISTENT']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: { "0": { NONEXISTENT: undefined } } }
        });
    });

    test('deeply nested path (4+ parts) uses first 3 parts for delta', () => {
        // "/XX/TABLE1/0/COL1/deep" → parts = ["TABLE1","0","COL1","deep"]
        // parts.length >= 3 ✓, !isNaN("0") ✓ → delta with parts[2] = "COL1"
        const paths = new Set(['/XX/TABLE1/0/COL1/deep']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        expect(result).toEqual({
            TABLE1: { __delta: { "0": { COL1: "A1" } } }
        });
    });
});

// ── 6. Row insert/delete scenarios ──────────────────────────────────────
test.describe('Row insert/delete scenarios', () => {

    test('cell edit after rows were added (backend roundtrip reset)', () => {
        // Simulates: backend added 2 new rows, user edits cell in new row
        const xxAfterInsert = {
            TABLE1: [
                { COL1: "A1", COL2: "B1" },
                { COL1: "A2", COL2: "B2" },
                { COL1: "A3", COL2: "B3" },
                { COL1: "NEW1", COL2: "NEW_B1" },  // inserted by backend
                { COL1: "NEW2", COL2: "NEW_B2" },  // inserted by backend
            ],
        };
        // After roundtrip, Set was reset. User now edits cell in new row 3:
        const paths = new Set(['/XX/TABLE1/3/COL2']);
        const result = _buildDeltaFromPaths(paths, xxAfterInsert);
        expect(result).toEqual({
            TABLE1: { __delta: { "3": { COL2: "NEW_B1" } } }
        });
    });

    test('cell edit after rows were deleted (backend roundtrip reset)', () => {
        // Simulates: backend removed row 0, indices shifted
        const xxAfterDelete = {
            TABLE1: [
                { COL1: "A2", COL2: "B2" },  // was index 1, now index 0
                { COL1: "A3", COL2: "B3" },  // was index 2, now index 1
            ],
        };
        // After roundtrip reset, user edits row 0 (previously row 1):
        const paths = new Set(['/XX/TABLE1/0/COL1']);
        const result = _buildDeltaFromPaths(paths, xxAfterDelete);
        expect(result).toEqual({
            TABLE1: { __delta: { "0": { COL1: "A2" } } }
        });
    });

    test('full table replacement via setProperty sends complete array', () => {
        // Simulates client-side: model.setProperty("/XX/TABLE1", newArray)
        const xxWithNewTable = {
            TABLE1: [
                { COL1: "X1" },
                { COL1: "X2" },
            ],
        };
        const paths = new Set(['/XX/TABLE1']);
        const result = _buildDeltaFromPaths(paths, xxWithNewTable);
        expect(result).toEqual({
            TABLE1: [{ COL1: "X1" }, { COL1: "X2" }]
        });
    });
});

// ── 7. Overwrite behavior ───────────────────────────────────────────────
test.describe('Overwrite / priority behavior', () => {

    test('full-table path after cell path overwrites delta with full array', () => {
        // If both a cell path AND a full-table path exist for the same attribute,
        // iteration order of Set determines which wins (last write wins)
        const paths = new Set(['/XX/TABLE1/0/COL1', '/XX/TABLE1']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        // The full-table path "/XX/TABLE1" comes second → overwrites the delta
        expect(result).toEqual({ TABLE1: SAMPLE_XX.TABLE1 });
    });

    test('cell path after full-table path overwrites array with delta', () => {
        const paths = new Set(['/XX/TABLE1', '/XX/TABLE1/0/COL1']);
        const result = _buildDeltaFromPaths(paths, SAMPLE_XX);
        // The cell path comes second → overwrites with __delta
        expect(result).toEqual({
            TABLE1: { __delta: { "0": { COL1: "A1" } } }
        });
    });
});
