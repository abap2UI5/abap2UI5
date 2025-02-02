"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.WebSocketRouteDispatcher = void 0;
var _page = require("../page");
var _dispatcher = require("./dispatcher");
var _utils = require("../../utils");
var _pageDispatcher = require("./pageDispatcher");
var webSocketMockSource = _interopRequireWildcard(require("../../generated/webSocketMockSource"));
var _eventsHelper = require("../../utils/eventsHelper");
var _class;
/**
 * Copyright (c) Microsoft Corporation.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
function _getRequireWildcardCache(e) { if ("function" != typeof WeakMap) return null; var r = new WeakMap(), t = new WeakMap(); return (_getRequireWildcardCache = function (e) { return e ? t : r; })(e); }
function _interopRequireWildcard(e, r) { if (!r && e && e.__esModule) return e; if (null === e || "object" != typeof e && "function" != typeof e) return { default: e }; var t = _getRequireWildcardCache(r); if (t && t.has(e)) return t.get(e); var n = { __proto__: null }, a = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var u in e) if ("default" !== u && Object.prototype.hasOwnProperty.call(e, u)) { var i = a ? Object.getOwnPropertyDescriptor(e, u) : null; i && (i.get || i.set) ? Object.defineProperty(n, u, i) : n[u] = e[u]; } return n.default = e, t && t.set(e, n), n; }
const kBindingInstalledSymbol = Symbol('webSocketRouteBindingInstalled');
const kInitScriptInstalledSymbol = Symbol('webSocketRouteInitScriptInstalled');
class WebSocketRouteDispatcher extends _dispatcher.Dispatcher {
  constructor(scope, id, url, frame) {
    super(scope, {
      guid: 'webSocketRoute@' + (0, _utils.createGuid)()
    }, 'WebSocketRoute', {
      url
    });
    this._type_WebSocketRoute = true;
    this._id = void 0;
    this._frame = void 0;
    this._id = id;
    this._frame = frame;
    this._eventListeners.push(
    // When the frame navigates or detaches, there will be no more communication
    // from the mock websocket, so pretend like it was closed.
    _eventsHelper.eventsHelper.addEventListener(frame._page, _page.Page.Events.InternalFrameNavigatedToNewDocument, frame => {
      if (frame === this._frame) this._executionContextGone();
    }), _eventsHelper.eventsHelper.addEventListener(frame._page, _page.Page.Events.FrameDetached, frame => {
      if (frame === this._frame) this._executionContextGone();
    }), _eventsHelper.eventsHelper.addEventListener(frame._page, _page.Page.Events.Close, () => this._executionContextGone()), _eventsHelper.eventsHelper.addEventListener(frame._page, _page.Page.Events.Crash, () => this._executionContextGone()));
    WebSocketRouteDispatcher._idToDispatcher.set(this._id, this);
    scope._dispatchEvent('webSocketRoute', {
      webSocketRoute: this
    });
  }
  static async installIfNeeded(contextDispatcher, target) {
    const context = target instanceof _page.Page ? target.context() : target;
    if (!context[kBindingInstalledSymbol]) {
      context[kBindingInstalledSymbol] = true;
      await context.exposeBinding('__pwWebSocketBinding', false, (source, payload) => {
        if (payload.type === 'onCreate') {
          const pageDispatcher = _pageDispatcher.PageDispatcher.fromNullable(contextDispatcher, source.page);
          let scope;
          if (pageDispatcher && matchesPattern(pageDispatcher, context._options.baseURL, payload.url)) scope = pageDispatcher;else if (matchesPattern(contextDispatcher, context._options.baseURL, payload.url)) scope = contextDispatcher;
          if (scope) {
            new WebSocketRouteDispatcher(scope, payload.id, payload.url, source.frame);
          } else {
            const request = {
              id: payload.id,
              type: 'passthrough'
            };
            source.frame.evaluateExpression(`globalThis.__pwWebSocketDispatch(${JSON.stringify(request)})`).catch(() => {});
          }
          return;
        }
        const dispatcher = WebSocketRouteDispatcher._idToDispatcher.get(payload.id);
        if (payload.type === 'onMessageFromPage') dispatcher === null || dispatcher === void 0 || dispatcher._dispatchEvent('messageFromPage', {
          message: payload.data.data,
          isBase64: payload.data.isBase64
        });
        if (payload.type === 'onMessageFromServer') dispatcher === null || dispatcher === void 0 || dispatcher._dispatchEvent('messageFromServer', {
          message: payload.data.data,
          isBase64: payload.data.isBase64
        });
        if (payload.type === 'onClosePage') dispatcher === null || dispatcher === void 0 || dispatcher._dispatchEvent('closePage', {
          code: payload.code,
          reason: payload.reason,
          wasClean: payload.wasClean
        });
        if (payload.type === 'onCloseServer') dispatcher === null || dispatcher === void 0 || dispatcher._dispatchEvent('closeServer', {
          code: payload.code,
          reason: payload.reason,
          wasClean: payload.wasClean
        });
      });
    }
    if (!target[kInitScriptInstalledSymbol]) {
      target[kInitScriptInstalledSymbol] = true;
      await target.addInitScript(`
        (() => {
          const module = {};
          ${webSocketMockSource.source}
          (module.exports.inject())(globalThis);
        })();
      `);
    }
  }
  async connect(params) {
    await this._evaluateAPIRequest({
      id: this._id,
      type: 'connect'
    });
  }
  async ensureOpened(params) {
    await this._evaluateAPIRequest({
      id: this._id,
      type: 'ensureOpened'
    });
  }
  async sendToPage(params) {
    await this._evaluateAPIRequest({
      id: this._id,
      type: 'sendToPage',
      data: {
        data: params.message,
        isBase64: params.isBase64
      }
    });
  }
  async sendToServer(params) {
    await this._evaluateAPIRequest({
      id: this._id,
      type: 'sendToServer',
      data: {
        data: params.message,
        isBase64: params.isBase64
      }
    });
  }
  async closePage(params) {
    await this._evaluateAPIRequest({
      id: this._id,
      type: 'closePage',
      code: params.code,
      reason: params.reason,
      wasClean: params.wasClean
    });
  }
  async closeServer(params) {
    await this._evaluateAPIRequest({
      id: this._id,
      type: 'closeServer',
      code: params.code,
      reason: params.reason,
      wasClean: params.wasClean
    });
  }
  async _evaluateAPIRequest(request) {
    await this._frame.evaluateExpression(`globalThis.__pwWebSocketDispatch(${JSON.stringify(request)})`).catch(() => {});
  }
  _onDispose() {
    WebSocketRouteDispatcher._idToDispatcher.delete(this._id);
  }
  _executionContextGone() {
    // We could enter here after being disposed upon page closure:
    // - first from the recursive dispose inintiated by PageDispatcher;
    // - then from our own page.on('close') listener.
    if (!this._disposed) {
      this._dispatchEvent('closePage', {
        wasClean: true
      });
      this._dispatchEvent('closeServer', {
        wasClean: true
      });
    }
  }
}
exports.WebSocketRouteDispatcher = WebSocketRouteDispatcher;
_class = WebSocketRouteDispatcher;
WebSocketRouteDispatcher._idToDispatcher = new Map();
function matchesPattern(dispatcher, baseURL, url) {
  for (const pattern of dispatcher._webSocketInterceptionPatterns || []) {
    const urlMatch = pattern.regexSource ? new RegExp(pattern.regexSource, pattern.regexFlags) : pattern.glob;
    if ((0, _utils.urlMatches)(baseURL, url, urlMatch)) return true;
  }
  return false;
}