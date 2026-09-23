import js from "@eslint/js";
import globals from "globals";

export default [
  {
    files: ["webapp/**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "script",
      globals: {
        ...globals.browser,
        // UI5 framework global. There is deliberately no `z2ui5` entry: the
        // frontend has no global of its own (shared state lives in
        // core/AppState.js), so no-undef reports any `z2ui5.x` access.
        sap: "readonly",
      },
    },
    linterOptions: {
      reportUnusedDisableDirectives: "warn",
    },
    rules: {
      ...js.configs.recommended.rules,
      // The frontend evaluates no code it receives: follow-up actions are
      // data, dispatched by name (core/FrontendAction.js).
      "no-new-func": "error",
      // Many handlers intentionally swallow errors after logging them via
      // Lib.logError; unused catch parameters are accepted.
      "no-unused-vars": [
        "error",
        { caughtErrors: "none", argsIgnorePattern: "^_" },
      ],
      // Beginner guard rails: always use === (the deliberate `x == null`
      // null-or-undefined idiom stays allowed via "smart"), and use const
      // for bindings that are never reassigned.
      eqeqeq: ["error", "smart"],
      "prefer-const": "error",
    },
  },
];
