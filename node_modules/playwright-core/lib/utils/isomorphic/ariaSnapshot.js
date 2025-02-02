"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.AriaKeyError = void 0;
exports.parseAriaKey = parseAriaKey;
exports.parseYamlTemplate = parseYamlTemplate;
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

// https://www.w3.org/TR/wai-aria-1.2/#role_definitions

function parseYamlTemplate(fragment) {
  const result = {
    kind: 'role',
    role: 'fragment'
  };
  populateNode(result, fragment);
  if (result.children && result.children.length === 1) return result.children[0];
  return result;
}
function populateNode(node, container) {
  for (const object of container) {
    if (typeof object === 'string') {
      const childNode = KeyParser.parse(object);
      node.children = node.children || [];
      node.children.push(childNode);
      continue;
    }
    for (const key of Object.keys(object)) {
      node.children = node.children || [];
      const value = object[key];
      if (key === 'text') {
        node.children.push({
          kind: 'text',
          text: valueOrRegex(value)
        });
        continue;
      }
      const childNode = KeyParser.parse(key);
      if (childNode.kind === 'text') {
        node.children.push({
          kind: 'text',
          text: valueOrRegex(value)
        });
        continue;
      }
      if (typeof value === 'string') {
        node.children.push({
          ...childNode,
          children: [{
            kind: 'text',
            text: valueOrRegex(value)
          }]
        });
        continue;
      }
      node.children.push(childNode);
      populateNode(childNode, value);
    }
  }
}
function normalizeWhitespace(text) {
  return text.replace(/[\r\n\s\t]+/g, ' ').trim();
}
function valueOrRegex(value) {
  return value.startsWith('/') && value.endsWith('/') ? new RegExp(value.slice(1, -1)) : normalizeWhitespace(value);
}
class KeyParser {
  static parse(input) {
    return new KeyParser(input)._parse();
  }
  constructor(input) {
    this._input = void 0;
    this._pos = void 0;
    this._length = void 0;
    this._input = input;
    this._pos = 0;
    this._length = input.length;
  }
  _peek() {
    return this._input[this._pos] || '';
  }
  _next() {
    if (this._pos < this._length) return this._input[this._pos++];
    return null;
  }
  _eof() {
    return this._pos >= this._length;
  }
  _isWhitespace() {
    return !this._eof() && /\s/.test(this._peek());
  }
  _skipWhitespace() {
    while (this._isWhitespace()) this._pos++;
  }
  _readIdentifier(type) {
    if (this._eof()) this._throwError(`Unexpected end of input when expecting ${type}`);
    const start = this._pos;
    while (!this._eof() && /[a-zA-Z]/.test(this._peek())) this._pos++;
    return this._input.slice(start, this._pos);
  }
  _readString() {
    let result = '';
    let escaped = false;
    while (!this._eof()) {
      const ch = this._next();
      if (escaped) {
        result += ch;
        escaped = false;
      } else if (ch === '\\') {
        escaped = true;
      } else if (ch === '"') {
        return result;
      } else {
        result += ch;
      }
    }
    this._throwError('Unterminated string');
  }
  _throwError(message, pos) {
    throw new AriaKeyError(message, this._input, pos || this._pos);
  }
  _readRegex() {
    let result = '';
    let escaped = false;
    let insideClass = false;
    while (!this._eof()) {
      const ch = this._next();
      if (escaped) {
        result += ch;
        escaped = false;
      } else if (ch === '\\') {
        escaped = true;
        result += ch;
      } else if (ch === '/' && !insideClass) {
        return result;
      } else if (ch === '[') {
        insideClass = true;
        result += ch;
      } else if (ch === ']' && insideClass) {
        result += ch;
        insideClass = false;
      } else {
        result += ch;
      }
    }
    this._throwError('Unterminated regex');
  }
  _readStringOrRegex() {
    const ch = this._peek();
    if (ch === '"') {
      this._next();
      return this._readString();
    }
    if (ch === '/') {
      this._next();
      return new RegExp(this._readRegex());
    }
    return null;
  }
  _readAttributes(result) {
    let errorPos = this._pos;
    while (true) {
      this._skipWhitespace();
      if (this._peek() === '[') {
        this._next();
        this._skipWhitespace();
        errorPos = this._pos;
        const flagName = this._readIdentifier('attribute');
        this._skipWhitespace();
        let flagValue = '';
        if (this._peek() === '=') {
          this._next();
          this._skipWhitespace();
          errorPos = this._pos;
          while (this._peek() !== ']' && !this._isWhitespace() && !this._eof()) flagValue += this._next();
        }
        this._skipWhitespace();
        if (this._peek() !== ']') this._throwError('Expected ]');
        this._next(); // Consume ']'
        this._applyAttribute(result, flagName, flagValue || 'true', errorPos);
      } else {
        break;
      }
    }
  }
  _parse() {
    this._skipWhitespace();
    const role = this._readIdentifier('role');
    this._skipWhitespace();
    const name = this._readStringOrRegex() || '';
    const result = {
      kind: 'role',
      role,
      name
    };
    this._readAttributes(result);
    this._skipWhitespace();
    if (!this._eof()) this._throwError('Unexpected input');
    return result;
  }
  _applyAttribute(node, key, value, errorPos) {
    if (key === 'checked') {
      this._assert(value === 'true' || value === 'false' || value === 'mixed', 'Value of "checked\" attribute must be a boolean or "mixed"', errorPos);
      node.checked = value === 'true' ? true : value === 'false' ? false : 'mixed';
      return;
    }
    if (key === 'disabled') {
      this._assert(value === 'true' || value === 'false', 'Value of "disabled" attribute must be a boolean', errorPos);
      node.disabled = value === 'true';
      return;
    }
    if (key === 'expanded') {
      this._assert(value === 'true' || value === 'false', 'Value of "expanded" attribute must be a boolean', errorPos);
      node.expanded = value === 'true';
      return;
    }
    if (key === 'level') {
      this._assert(!isNaN(Number(value)), 'Value of "level" attribute must be a number', errorPos);
      node.level = Number(value);
      return;
    }
    if (key === 'pressed') {
      this._assert(value === 'true' || value === 'false' || value === 'mixed', 'Value of "pressed" attribute must be a boolean or "mixed"', errorPos);
      node.pressed = value === 'true' ? true : value === 'false' ? false : 'mixed';
      return;
    }
    if (key === 'selected') {
      this._assert(value === 'true' || value === 'false', 'Value of "selected" attribute must be a boolean', errorPos);
      node.selected = value === 'true';
      return;
    }
    this._assert(false, `Unsupported attribute [${key}]`, errorPos);
  }
  _assert(value, message, valuePos) {
    if (!value) this._throwError(message || 'Assertion error', valuePos);
  }
}
function parseAriaKey(key) {
  return KeyParser.parse(key);
}
class AriaKeyError extends Error {
  constructor(message, input, pos) {
    super(message + ':\n\n' + input + '\n' + ' '.repeat(pos) + '^\n');
    this.shortMessage = void 0;
    this.pos = void 0;
    this.shortMessage = message;
    this.pos = pos;
    this.stack = undefined;
  }
}
exports.AriaKeyError = AriaKeyError;