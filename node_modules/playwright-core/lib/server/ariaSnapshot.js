"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parseAriaSnapshot = parseAriaSnapshot;
exports.parseYamlForAriaSnapshot = parseYamlForAriaSnapshot;
var _ariaSnapshot = require("../utils/isomorphic/ariaSnapshot");
var _utilsBundle = require("../utilsBundle");
/**
 * Copyright (c) Microsoft Corporation.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function parseAriaSnapshot(text) {
  return (0, _ariaSnapshot.parseYamlTemplate)(parseYamlForAriaSnapshot(text));
}
function parseYamlForAriaSnapshot(text) {
  const parsed = _utilsBundle.yaml.parse(text);
  if (!Array.isArray(parsed)) throw new Error('Expected object key starting with "- ":\n\n' + text + '\n');
  return parsed;
}