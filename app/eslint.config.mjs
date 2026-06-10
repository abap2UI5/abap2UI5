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
        // UI5 framework global
        sap: "readonly",
        // Shared abap2UI5 state object. Declared by the backend-generated
        // HTML page; Component.js re-creates it when running standalone,
        // therefore it must be writable.
        z2ui5: "writable",
      },
    },
    linterOptions: {
      reportUnusedDisableDirectives: "warn",
    },
    rules: {
      ...js.configs.recommended.rules,
      // The backend can send custom JS snippets that are executed via the
      // Function constructor in Server.js. Keep this visible as an explicit
      // eslint-disable at the single place where it is allowed.
      "no-new-func": "error",
      // Many handlers intentionally swallow errors after logging them to
      // z2ui5.errors; unused catch parameters are accepted.
      "no-unused-vars": [
        "error",
        { caughtErrors: "none", argsIgnorePattern: "^_" },
      ],
    },
  },
];
