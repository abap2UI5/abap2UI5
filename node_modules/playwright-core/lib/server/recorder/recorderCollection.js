"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.RecorderCollection = void 0;
var _events = require("events");
var _time = require("../../utils/time");
var _recorderUtils = require("./recorderUtils");
var _errors = require("../errors");
var _recorderRunner = require("./recorderRunner");
var _debug = require("../../utils/debug");
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

class RecorderCollection extends _events.EventEmitter {
  constructor(pageAliases) {
    super();
    this._actions = [];
    this._enabled = false;
    this._pageAliases = void 0;
    this._pageAliases = pageAliases;
  }
  restart() {
    this._actions = [];
    this.emit('change', []);
  }
  setEnabled(enabled) {
    this._enabled = enabled;
  }
  async performAction(actionInContext) {
    await this._addAction(actionInContext, async callMetadata => {
      await (0, _recorderRunner.performAction)(callMetadata, this._pageAliases, actionInContext);
    });
  }
  addRecordedAction(actionInContext) {
    if (['openPage', 'closePage'].includes(actionInContext.action.name)) {
      this._actions.push(actionInContext);
      this._fireChange();
      return;
    }
    this._addAction(actionInContext).catch(() => {});
  }
  async _addAction(actionInContext, callback) {
    if (!this._enabled) return;
    if (actionInContext.action.name === 'openPage' || actionInContext.action.name === 'closePage') {
      this._actions.push(actionInContext);
      this._fireChange();
      return;
    }
    const {
      callMetadata,
      mainFrame
    } = (0, _recorderUtils.callMetadataForAction)(this._pageAliases, actionInContext);
    await mainFrame.instrumentation.onBeforeCall(mainFrame, callMetadata);
    this._actions.push(actionInContext);
    this._fireChange();
    const error = await (callback === null || callback === void 0 ? void 0 : callback(callMetadata).catch(e => e));
    callMetadata.endTime = (0, _time.monotonicTime)();
    actionInContext.endTime = callMetadata.endTime;
    callMetadata.error = error ? (0, _errors.serializeError)(error) : undefined;
    // Do not wait for onAfterCall so that performAction returned immediately after the action.
    mainFrame.instrumentation.onAfterCall(mainFrame, callMetadata).then(() => {
      this._fireChange();
    }).catch(() => {});
  }
  signal(pageAlias, frame, signal) {
    if (!this._enabled) return;
    if (signal.name === 'navigation' && frame._page.mainFrame() === frame) {
      const timestamp = (0, _time.monotonicTime)();
      const lastAction = this._actions[this._actions.length - 1];
      const signalThreshold = (0, _debug.isUnderTest)() ? 500 : 5000;
      let generateGoto = false;
      if (!lastAction) generateGoto = true;else if (lastAction.action.name !== 'click' && lastAction.action.name !== 'press') generateGoto = true;else if (timestamp - lastAction.startTime > signalThreshold) generateGoto = true;
      if (generateGoto) {
        this.addRecordedAction({
          frame: {
            pageAlias,
            framePath: []
          },
          action: {
            name: 'navigate',
            url: frame.url(),
            signals: []
          },
          startTime: timestamp,
          endTime: timestamp
        });
      }
      return;
    }
    if (this._actions.length) {
      this._actions[this._actions.length - 1].action.signals.push(signal);
      this._fireChange();
      return;
    }
  }
  _fireChange() {
    if (!this._enabled) return;
    this.emit('change', (0, _recorderUtils.collapseActions)(this._actions));
  }
}
exports.RecorderCollection = RecorderCollection;