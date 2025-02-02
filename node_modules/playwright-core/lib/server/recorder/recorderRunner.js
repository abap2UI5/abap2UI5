"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.performAction = performAction;
exports.toClickOptions = toClickOptions;
var _utils = require("../../utils");
var _language = require("../codegen/language");
var _recorderUtils = require("./recorderUtils");
var _recorderUtils2 = require("../../utils/isomorphic/recorderUtils");
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

async function performAction(callMetadata, pageAliases, actionInContext) {
  const mainFrame = (0, _recorderUtils.mainFrameForAction)(pageAliases, actionInContext);
  const {
    action
  } = actionInContext;
  const kActionTimeout = 5000;
  if (action.name === 'navigate') {
    await mainFrame.goto(callMetadata, action.url, {
      timeout: kActionTimeout
    });
    return;
  }
  if (action.name === 'openPage') throw Error('Not reached');
  if (action.name === 'closePage') {
    await mainFrame._page.close(callMetadata);
    return;
  }
  const selector = (0, _recorderUtils2.buildFullSelector)(actionInContext.frame.framePath, action.selector);
  if (action.name === 'click') {
    const options = toClickOptions(action);
    await mainFrame.click(callMetadata, selector, {
      ...options,
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'press') {
    const modifiers = (0, _language.toKeyboardModifiers)(action.modifiers);
    const shortcut = [...modifiers, action.key].join('+');
    await mainFrame.press(callMetadata, selector, shortcut, {
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'fill') {
    await mainFrame.fill(callMetadata, selector, action.text, {
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'setInputFiles') {
    await mainFrame.setInputFiles(callMetadata, selector, {
      selector,
      payloads: [],
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'check') {
    await mainFrame.check(callMetadata, selector, {
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'uncheck') {
    await mainFrame.uncheck(callMetadata, selector, {
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'select') {
    const values = action.options.map(value => ({
      value
    }));
    await mainFrame.selectOption(callMetadata, selector, [], values, {
      timeout: kActionTimeout,
      strict: true
    });
    return;
  }
  if (action.name === 'assertChecked') {
    await mainFrame.expect(callMetadata, selector, {
      selector,
      expression: 'to.be.checked',
      isNot: !action.checked,
      timeout: kActionTimeout
    });
    return;
  }
  if (action.name === 'assertText') {
    await mainFrame.expect(callMetadata, selector, {
      selector,
      expression: 'to.have.text',
      expectedText: (0, _utils.serializeExpectedTextValues)([action.text], {
        matchSubstring: true,
        normalizeWhiteSpace: true
      }),
      isNot: false,
      timeout: kActionTimeout
    });
    return;
  }
  if (action.name === 'assertValue') {
    await mainFrame.expect(callMetadata, selector, {
      selector,
      expression: 'to.have.value',
      expectedValue: action.value,
      isNot: false,
      timeout: kActionTimeout
    });
    return;
  }
  if (action.name === 'assertVisible') {
    await mainFrame.expect(callMetadata, selector, {
      selector,
      expression: 'to.be.visible',
      isNot: false,
      timeout: kActionTimeout
    });
    return;
  }
  throw new Error('Internal error: unexpected action ' + action.name);
}
function toClickOptions(action) {
  const modifiers = (0, _language.toKeyboardModifiers)(action.modifiers);
  const options = {};
  if (action.button !== 'left') options.button = action.button;
  if (modifiers.length) options.modifiers = modifiers;
  if (action.clickCount > 1) options.clickCount = action.clickCount;
  if (action.position) options.position = action.position;
  return options;
}