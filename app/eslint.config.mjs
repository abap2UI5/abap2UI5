import js from '@eslint/js';
import globals from 'globals';

export default [
  {
    files: ['webapp/**/*.js'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'script',
      globals: {
        ...globals.browser,
        sap: 'readonly',
        z2ui5: 'writable',
      },
    },
    rules: {
      ...js.configs.recommended.rules,
      'no-var': 'error',
      'prefer-const': 'error',
      'eqeqeq': ['error', 'always', { null: 'ignore' }],
      'no-console': 'warn',
    },
  },
];
