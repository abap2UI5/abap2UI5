# Test Coverage Analysis — abap2UI5

## Executive Summary

The codebase has **43 test files** with approximately **345+ test methods** across ~7,550 lines of ABAP test code and ~292 lines of JavaScript test code. Coverage is **strategically imbalanced**: model/binding services are thoroughly tested, while the request processing pipeline and XML view builder — the two most critical areas — have only stub-level tests.

## Current Coverage by Layer

| Layer | Classes | With Tests | Coverage | Notes |
|-------|---------|-----------|----------|-------|
| Layer 0 (Utilities) | ~32 | 13 | 40% | Intentionally low — mirrored from external projects |
| Layer 1 (Core Engine) | 8 | 8 | 100% | All have test files, but depth varies wildly |
| Layer 2 (Public API) | ~35 | 22 | 63% | HTTP handler + custom controls untested |

## Well-Tested Areas

These areas have solid, meaningful test suites:

| Class | Test Lines | Test Methods | Quality |
|-------|-----------|-------------|---------|
| `z2ui5_cl_core_srv_model` | 1,001 | 20+ | Deep — serialization roundtrips, nested structures, DREFs, OREFs, delta apply |
| `z2ui5_cl_util` | 1,458 | 38+ | Deep — RTTI reflection, string ops, boolean conversion, XML, URL encoding |
| `z2ui5_cl_util_range` | 395 | 27+ | Deep — all SQL range operators, escaping, multi-entry |
| `z2ui5_cl_ajson_utilities` | 697 | multiple | Good — JSON parsing, type validation |
| `z2ui5_cl_core_srv_bind` | 348 | 4+ | Good — one-way/two-way binding paths, type checking |
| `buildDeltaFromPaths.spec.js` | 292 | 30+ | Excellent — delta model computation with edge cases |

## Critical Gaps — Prioritized Recommendations

### Priority 1: Core Request Pipeline (Highest Impact)

**Files:** `z2ui5_cl_core_handler` (258 lines), `z2ui5_cl_core_client` (430 lines), `z2ui5_cl_core_action` (210 lines)
**Current tests:** Stub-only (68 lines total — just instantiation checks)
**Risk:** A bug in any of these affects every single app

These three classes orchestrate the entire roundtrip. Currently they only have "can I instantiate this?" tests with no behavioral validation.

**Recommended tests:**
- **Handler:** Full request flow — JSON parsing, `main_begin()` with various payloads, `main_process()` state transitions, `response_abap_to_json()` output validation, view update flag logic, error/exception handling for malformed requests
- **Client:** `_bind()` / `_bind_edit()` return correct model paths, `_event()` generates correct JS, `view_display()` stores XML correctly, `nav_app_call()` / `nav_app_leave()` manage the app stack, `check_on_init()` / `check_on_event()` return correct booleans, `message_box_display()` / `message_toast_display()` set correct response data
- **Action:** `factory_by_frontend()` routing based on draft ID presence, `factory_first_start()` creates startup app correctly, `factory_stack_call()` / `factory_stack_leave()` manage app transitions, `prepare_app_stack()` preserves state correctly

### Priority 2: XML View Builder (Largest Untested Surface)

**File:** `z2ui5_cl_xml_view` (11,253 lines, 446 methods)
**Current tests:** 238 lines, 16 methods — covers <4% of methods
**Risk:** Most-used public API; every app calls this extensively

The existing tests only check that a few controls produce XML containing the right tag names. No tests validate property handling, nesting correctness, or the core `_generic()` method.

**Recommended tests:**
- **Core `_generic()` method:** Verify it creates correct XML nodes with properties, handles empty/null values, respects namespace parameter
- **Boolean property conversion:** Ensure `z2ui5_cl_util=>boolean_abap_2_json()` integration works correctly for `visible`, `editable`, `enabled` etc.
- **Property special characters:** XML escaping for `&`, `<`, `>`, `"` in property values
- **Deep nesting:** Build a realistic multi-level view (page > vbox > form > input) and validate the full XML structure
- **Aggregation methods:** Test `items()`, `columns()`, `cells()`, `content()`, `header()`, `footer()` generate correct XML aggregation tags
- **`get_parent()` chain:** Verify parent traversal works correctly at multiple nesting levels
- **`stringify()` output:** Validate complete XML output structure including namespace declarations
- **Commonly-used controls:** Add tests for `select`, `combobox`, `checkbox`, `date_picker`, `multi_input`, `flexible_column_layout`, `tree_table` — high-usage controls currently untested

### Priority 3: App State Persistence

**Files:** `z2ui5_cl_core_app` (186 lines), `z2ui5_cl_core_srv_draft` (125 lines)
**Current tests:** 69 + 33 lines — basic create/read only
**Risk:** State corruption, data loss between roundtrips

**Recommended tests:**
- **App serialization:** `model_json_stringify()` / `model_json_parse()` roundtrip with complex nested data (structures, tables, object references)
- **XML state:** `all_xml_stringify()` / `all_xml_parse()` preserving view/popup/nest XML
- **Draft lifecycle:** Create → read → verify data integrity, buffer caching behavior, cleanup of expired drafts
- **Edge cases:** Very large models, special characters in data, empty/initial models, models with data references

### Priority 4: Custom Controls Builder

**File:** `z2ui5_cl_xml_view_cc` (676 lines, ~30 methods)
**Current tests:** None
**Risk:** Advanced app features completely unvalidated

**Recommended tests:**
- Verify each custom control method generates XML with `z2ui5` namespace
- Test that custom controls integrate correctly with the main `z2ui5_cl_xml_view` builder
- Validate property passing for the most-used custom controls (`camera_picture`, `geolocation`, `bwip_js`, etc.)

### Priority 5: HTTP Handler

**File:** `z2ui5_cl_http_handler` (274 lines)
**Current tests:** None (tested indirectly via Node/Playwright integration)
**Risk:** Entry point for all requests; cloud vs. on-premise differences

**Recommended tests:**
- `factory()` vs `factory_cloud()` produce correct handler configurations
- `_http_get()` generates valid HTML with correct UI5 bootstrap
- `_http_post()` handles valid JSON, returns correct response structure
- Error handling for malformed POST bodies

## Qualitative Issues

### Missing Testing Patterns
1. **No negative path testing** — Almost no tests verify error conditions, exception handling, or invalid input behavior
2. **No mocking** — All tests use real objects; makes it hard to test components in isolation
3. **No integration tests** — No ABAP-level tests that exercise a full roundtrip (init → event → response → next event)
4. **Shallow popup tests** — Each popup has a test file, but most only test instantiation and factory methods, not actual dialog flows

### Existing Strengths to Build On
- `LOCAL FRIENDS` pattern already used for accessing private methods
- Consistent `FOR TESTING RISK LEVEL HARMLESS` annotations
- Good fixture patterns in `z2ui5_cl_core_srv_model` tests (can be reused)
- The transpiler-based test pipeline (`npm run unit`) works well

## Suggested Test Implementation Order

1. **z2ui5_cl_core_client** — Expand from 1 to ~15 test methods covering the main client API methods
2. **z2ui5_cl_core_handler** — Add 5-10 tests for request parsing, main flow, and response generation
3. **z2ui5_cl_core_action** — Add 5-8 tests for app routing and stack management
4. **z2ui5_cl_xml_view** — Add 20-30 tests for untested controls, properties, and nesting patterns
5. **z2ui5_cl_xml_view_cc** — Create test file with 10-15 tests for custom controls
6. **z2ui5_cl_core_app** — Expand serialization roundtrip tests
7. **z2ui5_cl_core_srv_draft** — Add buffer and cleanup tests
8. **z2ui5_cl_http_handler** — Create test file for HTTP entry point

## Metrics Target

| Metric | Current | Target |
|--------|---------|--------|
| Test methods (core pipeline) | 3 | 30+ |
| XML view test methods | 16 | 50+ |
| Classes with meaningful tests | ~15 | 25+ |
| Negative/error path tests | ~0 | 15+ |
| Integration roundtrip tests | 0 | 5+ |
