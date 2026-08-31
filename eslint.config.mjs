import js from "@eslint/js";
import globals from "globals";

/*
 * ESLint for the Node side of this repository.
 *
 * `app/eslint.config.mjs` is scoped to `files: ["webapp/**\/*.js"]` and runs
 * from inside `app/`, so it reaches the shipped frontend and nothing else.
 * Everything that BUILDS and CHECKS that frontend was uncovered: the CI gates
 * under `.github/scripts/`, the generators under `tools/`, the dev server and
 * the transpiler bootstrap under `node/`, and the JS unit specs under
 * `node/tests/`. Those scripts decide whether a pull request merges, and a
 * typo in one of them fails as a crash in CI rather than as a finding.
 *
 * Deliberately lean. The recommended set plus three rules the frontend config
 * already carries for the same reasons - this is tooling, and a house style
 * argued rule by rule would cost more than it catches. Formatting is not
 * ESLint's job here; there is no root Prettier and this config adds none.
 *
 * Three source shapes live side by side and each needs its own globals:
 *   - .mjs everywhere: ES modules on Node.
 *   - tools/app2abap/*.js and tools/app2bsp/*.js: CommonJS, `require`/`module`.
 *   - node/tests/*.spec.js: CommonJS too, and they run the REAL app/webapp
 *     modules through a stubbed sap.ui.define, so they touch browser globals.
 */
export default [
  {
    ignores: [
      // Generated or vendored trees. tools/out/ is written by
      // `npm run frontend:build` and node/downport, node/output and
      // node/deps by the downport/transpile pipeline; app/ has its own
      // config and is linted by `npm --prefix app run lint`.
      // (tools/out/ is git-ignored, but ESLint does not read .gitignore.)
      "app/**",
      "tools/out/**",
      "node/downport/**",
      "node/output/**",
      "node/deps/**",
      // the open-abap-core clone the e2e transpile checks out next to the
      // outputs - git-ignored like them, and vendored code either way
      "node/open-abap-core/**",
      "node/coverage/**",
      "tools/out/**",
      "node_modules/**",
    ],
  },
  {
    files: ["**/*.mjs"],
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: "module",
      globals: { ...globals.node },
    },
    linterOptions: { reportUnusedDisableDirectives: "warn" },
    rules: {
      ...js.configs.recommended.rules,
      // Same three as the frontend config: an unused catch binding is how a
      // deliberate swallow is written, `x == null` stays allowed, and a
      // binding that is never reassigned says so.
      "no-unused-vars": ["error", { caughtErrors: "none", argsIgnorePattern: "^_" }],
      eqeqeq: ["error", "smart"],
      "prefer-const": "error",
    },
  },
  {
    files: ["tools/**/*.js", "node/**/*.js"],
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: "commonjs",
      globals: { ...globals.node },
    },
    linterOptions: { reportUnusedDisableDirectives: "warn" },
    rules: {
      ...js.configs.recommended.rules,
      "no-unused-vars": ["error", { caughtErrors: "none", argsIgnorePattern: "^_" }],
      eqeqeq: ["error", "smart"],
      "prefer-const": "error",
    },
  },
  {
    // `.github/shared/` is the ecosystem's source copy of these scripts: the
    // same bytes run in samples, samples-controls and samples-stack, whose
    // configs are their own. A disable directive there answers to a ruleset
    // that is not this one, and reporting it as unused here would ask this
    // repository to edit a file the copies are compared against byte for byte
    // (`npm run check:shared`).
    files: [".github/shared/**/*.mjs"],
    linterOptions: { reportUnusedDisableDirectives: "off" },
  },
  {
    // The specs load app/webapp modules into a stubbed UI5 runtime, so they
    // build browser-shaped objects (window, document, URL, setTimeout) and
    // the `sap` and `z2ui5` globals the frontend config also declares.
    files: ["node/tests/**/*.js", "node/tests-examples/**/*.js"],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.browser,
        sap: "writable",
        z2ui5: "writable",
      },
    },
  },
];
