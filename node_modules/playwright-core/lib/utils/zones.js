"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.zones = exports.Zone = void 0;
var _async_hooks = require("async_hooks");
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

class ZoneManager {
  constructor() {
    this._asyncLocalStorage = new _async_hooks.AsyncLocalStorage();
  }
  run(type, data, func) {
    const zone = Zone._createWithData(this._asyncLocalStorage, type, data);
    return this._asyncLocalStorage.run(zone, func);
  }
  zoneData(type) {
    const zone = this._asyncLocalStorage.getStore();
    return zone === null || zone === void 0 ? void 0 : zone.get(type);
  }
  currentZone() {
    var _this$_asyncLocalStor;
    return (_this$_asyncLocalStor = this._asyncLocalStorage.getStore()) !== null && _this$_asyncLocalStor !== void 0 ? _this$_asyncLocalStor : Zone._createEmpty(this._asyncLocalStorage);
  }
  exitZones(func) {
    return this._asyncLocalStorage.run(undefined, func);
  }
}
class Zone {
  static _createWithData(asyncLocalStorage, type, data) {
    var _asyncLocalStorage$ge;
    const store = new Map((_asyncLocalStorage$ge = asyncLocalStorage.getStore()) === null || _asyncLocalStorage$ge === void 0 ? void 0 : _asyncLocalStorage$ge._data);
    store.set(type, data);
    return new Zone(asyncLocalStorage, store);
  }
  static _createEmpty(asyncLocalStorage) {
    return new Zone(asyncLocalStorage, new Map());
  }
  constructor(asyncLocalStorage, store) {
    this._asyncLocalStorage = void 0;
    this._data = void 0;
    this._asyncLocalStorage = asyncLocalStorage;
    this._data = store;
  }
  run(func) {
    // Reset apiZone and expectZone, but restore stepZone.
    const entries = [...this._data.entries()].filter(([type]) => type !== 'apiZone' && type !== 'expectZone');
    const resetZone = new Zone(this._asyncLocalStorage, new Map(entries));
    return this._asyncLocalStorage.run(resetZone, func);
  }
  get(type) {
    return this._data.get(type);
  }
}
exports.Zone = Zone;
const zones = exports.zones = new ZoneManager();