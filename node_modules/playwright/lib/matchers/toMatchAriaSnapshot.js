"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.toMatchAriaSnapshot = toMatchAriaSnapshot;
var _matcherHint = require("./matcherHint");
var _utilsBundle = require("playwright-core/lib/utilsBundle");
var _expectBundle = require("../common/expectBundle");
var _util = require("../util");
var _expect = require("./expect");
var _globals = require("../common/globals");
var _utils = require("playwright-core/lib/utils");
/**
 * Copyright Microsoft Corporation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

async function toMatchAriaSnapshot(receiver, expected, options = {}) {
  var _options$timeout;
  const matcherName = 'toMatchAriaSnapshot';
  const testInfo = (0, _globals.currentTestInfo)();
  if (!testInfo) throw new Error(`toMatchAriaSnapshot() must be called during the test`);
  if (testInfo._projectInternal.ignoreSnapshots) return {
    pass: !this.isNot,
    message: () => '',
    name: 'toMatchAriaSnapshot',
    expected
  };
  const updateSnapshots = testInfo.config.updateSnapshots;
  const matcherOptions = {
    isNot: this.isNot,
    promise: this.promise
  };
  if (typeof expected !== 'string') {
    throw new Error([(0, _matcherHint.matcherHint)(this, receiver, matcherName, receiver, expected, matcherOptions), `${_utilsBundle.colors.bold('Matcher error')}: ${(0, _expectBundle.EXPECTED_COLOR)('expected')} value must be a string`, this.utils.printWithType('Expected', expected, this.utils.printExpected)].join('\n\n'));
  }
  const generateMissingBaseline = updateSnapshots === 'missing' && !expected;
  const generateNewBaseline = updateSnapshots === 'all' || generateMissingBaseline;
  if (generateMissingBaseline) {
    if (this.isNot) {
      const message = `Matchers using ".not" can't generate new baselines`;
      return {
        pass: this.isNot,
        message: () => message,
        name: 'toMatchAriaSnapshot'
      };
    } else {
      // When generating new baseline, run entire pipeline against impossible match.
      expected = `- none "Generating new baseline"`;
    }
  }
  const timeout = (_options$timeout = options.timeout) !== null && _options$timeout !== void 0 ? _options$timeout : this.timeout;
  expected = unshift(expected);
  const {
    matches: pass,
    received,
    log,
    timedOut
  } = await receiver._expect('to.match.aria', {
    expectedValue: expected,
    isNot: this.isNot,
    timeout
  });
  const typedReceived = received;
  const messagePrefix = (0, _matcherHint.matcherHint)(this, receiver, matcherName, 'locator', undefined, matcherOptions, timedOut ? timeout : undefined);
  const notFound = typedReceived === _matcherHint.kNoElementsFoundError;
  if (notFound) {
    return {
      pass: this.isNot,
      message: () => messagePrefix + `Expected: ${this.utils.printExpected(expected)}\nReceived: ${(0, _expectBundle.EXPECTED_COLOR)('<element not found>')}` + (0, _util.callLogText)(log),
      name: 'toMatchAriaSnapshot',
      expected
    };
  }
  const receivedText = typedReceived.raw;
  const message = () => {
    if (pass) {
      if (notFound) return messagePrefix + `Expected: not ${this.utils.printExpected(expected)}\nReceived: ${receivedText}` + (0, _util.callLogText)(log);
      const printedReceived = (0, _expect.printReceivedStringContainExpectedSubstring)(receivedText, receivedText.indexOf(expected), expected.length);
      return messagePrefix + `Expected: not ${this.utils.printExpected(expected)}\nReceived: ${printedReceived}` + (0, _util.callLogText)(log);
    } else {
      const labelExpected = `Expected`;
      if (notFound) return messagePrefix + `${labelExpected}: ${this.utils.printExpected(expected)}\nReceived: ${receivedText}` + (0, _util.callLogText)(log);
      return messagePrefix + this.utils.printDiffOrStringify(expected, receivedText, labelExpected, 'Received', false) + (0, _util.callLogText)(log);
    }
  };
  if (!this.isNot && pass === this.isNot && generateNewBaseline) {
    // Only rebaseline failed snapshots.
    const suggestedRebaseline = `toMatchAriaSnapshot(\`\n${(0, _utils.escapeTemplateString)(indent(typedReceived.regex, '{indent}  '))}\n{indent}\`)`;
    return {
      pass: this.isNot,
      message: () => '',
      name: 'toMatchAriaSnapshot',
      suggestedRebaseline
    };
  }
  return {
    name: matcherName,
    expected,
    message,
    pass,
    actual: received,
    log,
    timeout: timedOut ? timeout : undefined
  };
}
function unshift(snapshot) {
  const lines = snapshot.split('\n');
  let whitespacePrefixLength = 100;
  for (const line of lines) {
    if (!line.trim()) continue;
    const match = line.match(/^(\s*)/);
    if (match && match[1].length < whitespacePrefixLength) whitespacePrefixLength = match[1].length;
    break;
  }
  return lines.filter(t => t.trim()).map(line => line.substring(whitespacePrefixLength)).join('\n');
}
function indent(snapshot, indent) {
  return snapshot.split('\n').map(line => indent + line).join('\n');
}