"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.RecorderInTraceViewer = void 0;
var _path = _interopRequireDefault(require("path"));
var _events = require("events");
var _traceViewer = require("../trace/viewer/traceViewer");
var _manualPromise = require("../../utils/manualPromise");
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
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

class RecorderInTraceViewer extends _events.EventEmitter {
  static factory(context) {
    return async recorder => {
      const transport = new RecorderTransport();
      const trace = _path.default.join(context._browser.options.tracesDir, 'trace');
      const {
        wsEndpointForTest,
        tracePage,
        traceServer
      } = await openApp(trace, {
        transport,
        headless: !context._browser.options.headful
      });
      return new RecorderInTraceViewer(transport, tracePage, traceServer, wsEndpointForTest);
    };
  }
  constructor(transport, tracePage, traceServer, wsEndpointForTest) {
    super();
    this.wsEndpointForTest = void 0;
    this._transport = void 0;
    this._tracePage = void 0;
    this._traceServer = void 0;
    this._transport = transport;
    this._transport.eventSink.resolve(this);
    this._tracePage = tracePage;
    this._traceServer = traceServer;
    this.wsEndpointForTest = wsEndpointForTest;
    this._tracePage.once('close', () => {
      this.close();
    });
  }
  async close() {
    await this._tracePage.context().close({
      reason: 'Recorder window closed'
    });
    await this._traceServer.stop();
  }
  async setPaused(paused) {
    this._transport.deliverEvent('setPaused', {
      paused
    });
  }
  async setMode(mode) {
    this._transport.deliverEvent('setMode', {
      mode
    });
  }
  async setRunningFile(file) {
    this._transport.deliverEvent('setRunningFile', {
      file
    });
  }
  async elementPicked(elementInfo, userGesture) {
    this._transport.deliverEvent('elementPicked', {
      elementInfo,
      userGesture
    });
  }
  async updateCallLogs(callLogs) {
    this._transport.deliverEvent('updateCallLogs', {
      callLogs
    });
  }
  async setSources(sources) {
    this._transport.deliverEvent('setSources', {
      sources
    });
    if (process.env.PWTEST_CLI_IS_UNDER_TEST && sources.length) {
      if (process._didSetSourcesForTest(sources[0].text)) this.close();
    }
  }
  async setActions(actions, sources) {
    this._transport.deliverEvent('setActions', {
      actions,
      sources
    });
  }
}
exports.RecorderInTraceViewer = RecorderInTraceViewer;
async function openApp(trace, options) {
  const traceServer = await (0, _traceViewer.startTraceViewerServer)(options);
  await (0, _traceViewer.installRootRedirect)(traceServer, [trace], {
    ...options,
    webApp: 'recorder.html'
  });
  const page = await (0, _traceViewer.openTraceViewerApp)(traceServer.urlPrefix('precise'), 'chromium', options);
  return {
    wsEndpointForTest: page.context()._browser.options.wsEndpoint,
    tracePage: page,
    traceServer
  };
}
class RecorderTransport {
  constructor() {
    this._connected = new _manualPromise.ManualPromise();
    this.eventSink = new _manualPromise.ManualPromise();
    this.sendEvent = void 0;
    this.close = void 0;
  }
  onconnect() {
    this._connected.resolve();
  }
  async dispatch(method, params) {
    const eventSink = await this.eventSink;
    eventSink.emit('event', {
      event: method,
      params
    });
  }
  onclose() {}
  deliverEvent(method, params) {
    this._connected.then(() => {
      var _this$sendEvent;
      return (_this$sendEvent = this.sendEvent) === null || _this$sendEvent === void 0 ? void 0 : _this$sendEvent.call(this, method, params);
    });
  }
}