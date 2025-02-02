"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.runWatchModeLoop = runWatchModeLoop;
var _readline = _interopRequireDefault(require("readline"));
var _path = _interopRequireDefault(require("path"));
var _utils = require("playwright-core/lib/utils");
var _utilsBundle = require("playwright-core/lib/utilsBundle");
var _utilsBundle2 = require("../utilsBundle");
var _base = require("../reporters/base");
var _playwrightServer = require("playwright-core/lib/remote/playwrightServer");
var _testServer = require("./testServer");
var _stream = require("stream");
var _testServerConnection = require("../isomorphic/testServerConnection");
var _teleSuiteUpdater = require("../isomorphic/teleSuiteUpdater");
var _configLoader = require("../common/configLoader");
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
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

class InMemoryTransport extends _stream.EventEmitter {
  constructor(send) {
    super();
    this._send = void 0;
    this._send = send;
  }
  close() {
    this.emit('close');
  }
  onclose(listener) {
    this.on('close', listener);
  }
  onerror(listener) {
    // no-op to fulfil the interface, the user of InMemoryTransport doesn't emit any errors.
  }
  onmessage(listener) {
    this.on('message', listener);
  }
  onopen(listener) {
    this.on('open', listener);
  }
  send(data) {
    this._send(data);
  }
}
async function runWatchModeLoop(configLocation, initialOptions) {
  if ((0, _configLoader.restartWithExperimentalTsEsm)(undefined, true)) return 'restarted';
  const options = {
    ...initialOptions
  };
  let bufferMode = false;
  const testServerDispatcher = new _testServer.TestServerDispatcher(configLocation, {});
  const transport = new InMemoryTransport(async data => {
    const {
      id,
      method,
      params
    } = JSON.parse(data);
    try {
      const result = await testServerDispatcher.transport.dispatch(method, params);
      transport.emit('message', JSON.stringify({
        id,
        result
      }));
    } catch (e) {
      transport.emit('message', JSON.stringify({
        id,
        error: String(e)
      }));
    }
  });
  testServerDispatcher.transport.sendEvent = (method, params) => {
    transport.emit('message', JSON.stringify({
      method,
      params
    }));
  };
  const testServerConnection = new _testServerConnection.TestServerConnection(transport);
  transport.emit('open');
  const teleSuiteUpdater = new _teleSuiteUpdater.TeleSuiteUpdater({
    pathSeparator: _path.default.sep,
    onUpdate() {}
  });
  const dirtyTestFiles = new Set();
  const dirtyTestIds = new Set();
  let onDirtyTests = new _utils.ManualPromise();
  let queue = Promise.resolve();
  const changedFiles = new Set();
  testServerConnection.onTestFilesChanged(({
    testFiles
  }) => {
    testFiles.forEach(file => changedFiles.add(file));
    queue = queue.then(async () => {
      if (changedFiles.size === 0) return;
      const {
        report
      } = await testServerConnection.listTests({
        locations: options.files,
        projects: options.projects,
        grep: options.grep
      });
      teleSuiteUpdater.processListReport(report);
      for (const test of teleSuiteUpdater.rootSuite.allTests()) {
        if (changedFiles.has(test.location.file)) {
          dirtyTestFiles.add(test.location.file);
          dirtyTestIds.add(test.id);
        }
      }
      changedFiles.clear();
      if (dirtyTestIds.size > 0) {
        onDirtyTests.resolve('changed');
        onDirtyTests = new _utils.ManualPromise();
      }
    });
  });
  testServerConnection.onReport(report => teleSuiteUpdater.processTestReportEvent(report));
  await testServerConnection.initialize({
    interceptStdio: false,
    watchTestDirs: true,
    populateDependenciesOnList: true
  });
  await testServerConnection.runGlobalSetup({});
  const {
    report
  } = await testServerConnection.listTests({});
  teleSuiteUpdater.processListReport(report);
  const projectNames = teleSuiteUpdater.rootSuite.suites.map(s => s.title);
  let lastRun = {
    type: 'regular'
  };
  let result = 'passed';
  while (true) {
    if (bufferMode) printBufferPrompt(dirtyTestFiles, teleSuiteUpdater.config.rootDir);else printPrompt();
    const waitForCommand = readCommand();
    const command = await Promise.race([onDirtyTests, waitForCommand.result]);
    if (command === 'changed') waitForCommand.cancel();
    if (bufferMode && command === 'changed') continue;
    const shouldRunChangedFiles = bufferMode ? command === 'run' : command === 'changed';
    if (shouldRunChangedFiles) {
      if (dirtyTestIds.size === 0) continue;
      const testIds = [...dirtyTestIds];
      dirtyTestIds.clear();
      dirtyTestFiles.clear();
      await runTests(options, testServerConnection, {
        testIds,
        title: 'files changed'
      });
      lastRun = {
        type: 'changed',
        dirtyTestIds: testIds
      };
      continue;
    }
    if (command === 'run') {
      // All means reset filters.
      await runTests(options, testServerConnection);
      lastRun = {
        type: 'regular'
      };
      continue;
    }
    if (command === 'project') {
      const {
        selectedProjects
      } = await _utilsBundle2.enquirer.prompt({
        type: 'multiselect',
        name: 'selectedProjects',
        message: 'Select projects',
        choices: projectNames
      }).catch(() => ({
        selectedProjects: null
      }));
      if (!selectedProjects) continue;
      options.projects = selectedProjects.length ? selectedProjects : undefined;
      await runTests(options, testServerConnection);
      lastRun = {
        type: 'regular'
      };
      continue;
    }
    if (command === 'file') {
      const {
        filePattern
      } = await _utilsBundle2.enquirer.prompt({
        type: 'text',
        name: 'filePattern',
        message: 'Input filename pattern (regex)'
      }).catch(() => ({
        filePattern: null
      }));
      if (filePattern === null) continue;
      if (filePattern.trim()) options.files = filePattern.split(' ');else options.files = undefined;
      await runTests(options, testServerConnection);
      lastRun = {
        type: 'regular'
      };
      continue;
    }
    if (command === 'grep') {
      const {
        testPattern
      } = await _utilsBundle2.enquirer.prompt({
        type: 'text',
        name: 'testPattern',
        message: 'Input test name pattern (regex)'
      }).catch(() => ({
        testPattern: null
      }));
      if (testPattern === null) continue;
      if (testPattern.trim()) options.grep = testPattern;else options.grep = undefined;
      await runTests(options, testServerConnection);
      lastRun = {
        type: 'regular'
      };
      continue;
    }
    if (command === 'failed') {
      const failedTestIds = teleSuiteUpdater.rootSuite.allTests().filter(t => !t.ok()).map(t => t.id);
      await runTests({}, testServerConnection, {
        title: 'running failed tests',
        testIds: failedTestIds
      });
      lastRun = {
        type: 'failed',
        failedTestIds
      };
      continue;
    }
    if (command === 'repeat') {
      if (lastRun.type === 'regular') {
        await runTests(options, testServerConnection, {
          title: 're-running tests'
        });
        continue;
      } else if (lastRun.type === 'changed') {
        await runTests(options, testServerConnection, {
          title: 're-running tests',
          testIds: lastRun.dirtyTestIds
        });
      } else if (lastRun.type === 'failed') {
        await runTests({}, testServerConnection, {
          title: 're-running tests',
          testIds: lastRun.failedTestIds
        });
      }
      continue;
    }
    if (command === 'toggle-show-browser') {
      await toggleShowBrowser();
      continue;
    }
    if (command === 'toggle-buffer-mode') {
      bufferMode = !bufferMode;
      continue;
    }
    if (command === 'exit') break;
    if (command === 'interrupted') {
      result = 'interrupted';
      break;
    }
  }
  const teardown = await testServerConnection.runGlobalTeardown({});
  return result === 'passed' ? teardown.status : result;
}
function readKeyPress(handler) {
  const promise = new _utils.ManualPromise();
  const rl = _readline.default.createInterface({
    input: process.stdin,
    escapeCodeTimeout: 50
  });
  _readline.default.emitKeypressEvents(process.stdin, rl);
  if (process.stdin.isTTY) process.stdin.setRawMode(true);
  const listener = _utils.eventsHelper.addEventListener(process.stdin, 'keypress', (text, key) => {
    const result = handler(text, key);
    if (result) promise.resolve(result);
  });
  const cancel = () => {
    _utils.eventsHelper.removeEventListeners([listener]);
    rl.close();
    if (process.stdin.isTTY) process.stdin.setRawMode(false);
  };
  void promise.finally(cancel);
  return {
    result: promise,
    cancel
  };
}
const isInterrupt = (text, key) => text === '\x03' || text === '\x1B' || key && key.name === 'escape' || key && key.ctrl && key.name === 'c';
async function runTests(watchOptions, testServerConnection, options) {
  printConfiguration(watchOptions, options === null || options === void 0 ? void 0 : options.title);
  const waitForDone = readKeyPress((text, key) => {
    if (isInterrupt(text, key)) {
      testServerConnection.stopTestsNoReply({});
      return 'done';
    }
  });
  await testServerConnection.runTests({
    grep: watchOptions.grep,
    testIds: options === null || options === void 0 ? void 0 : options.testIds,
    locations: watchOptions === null || watchOptions === void 0 ? void 0 : watchOptions.files,
    projects: watchOptions.projects,
    connectWsEndpoint,
    reuseContext: connectWsEndpoint ? true : undefined,
    workers: connectWsEndpoint ? 1 : undefined,
    headed: connectWsEndpoint ? true : undefined
  }).finally(() => waitForDone.cancel());
}
function readCommand() {
  return readKeyPress((text, key) => {
    if (isInterrupt(text, key)) return 'interrupted';
    if (process.platform !== 'win32' && key && key.ctrl && key.name === 'z') {
      process.kill(process.ppid, 'SIGTSTP');
      process.kill(process.pid, 'SIGTSTP');
    }
    const name = key === null || key === void 0 ? void 0 : key.name;
    if (name === 'q') return 'exit';
    if (name === 'h') {
      process.stdout.write(`${(0, _base.separator)()}
Run tests
  ${_utilsBundle.colors.bold('enter')}    ${_utilsBundle.colors.dim('run tests')}
  ${_utilsBundle.colors.bold('f')}        ${_utilsBundle.colors.dim('run failed tests')}
  ${_utilsBundle.colors.bold('r')}        ${_utilsBundle.colors.dim('repeat last run')}
  ${_utilsBundle.colors.bold('q')}        ${_utilsBundle.colors.dim('quit')}

Change settings
  ${_utilsBundle.colors.bold('c')}        ${_utilsBundle.colors.dim('set project')}
  ${_utilsBundle.colors.bold('p')}        ${_utilsBundle.colors.dim('set file filter')}
  ${_utilsBundle.colors.bold('t')}        ${_utilsBundle.colors.dim('set title filter')}
  ${_utilsBundle.colors.bold('s')}        ${_utilsBundle.colors.dim('toggle show & reuse the browser')}
  ${_utilsBundle.colors.bold('b')}        ${_utilsBundle.colors.dim('toggle buffer mode')}
`);
      return;
    }
    switch (name) {
      case 'return':
        return 'run';
      case 'r':
        return 'repeat';
      case 'c':
        return 'project';
      case 'p':
        return 'file';
      case 't':
        return 'grep';
      case 'f':
        return 'failed';
      case 's':
        return 'toggle-show-browser';
      case 'b':
        return 'toggle-buffer-mode';
    }
  });
}
let showBrowserServer;
let connectWsEndpoint = undefined;
let seq = 1;
function printConfiguration(options, title) {
  const packageManagerCommand = (0, _utils.getPackageManagerExecCommand)();
  const tokens = [];
  tokens.push(`${packageManagerCommand} playwright test`);
  if (options.projects) tokens.push(...options.projects.map(p => _utilsBundle.colors.blue(`--project ${p}`)));
  if (options.grep) tokens.push(_utilsBundle.colors.red(`--grep ${options.grep}`));
  if (options.files) tokens.push(...options.files.map(a => _utilsBundle.colors.bold(a)));
  if (title) tokens.push(_utilsBundle.colors.dim(`(${title})`));
  tokens.push(_utilsBundle.colors.dim(`#${seq++}`));
  const lines = [];
  const sep = (0, _base.separator)();
  lines.push('\x1Bc' + sep);
  lines.push(`${tokens.join(' ')}`);
  lines.push(`${_utilsBundle.colors.dim('Show & reuse browser:')} ${_utilsBundle.colors.bold(showBrowserServer ? 'on' : 'off')}`);
  process.stdout.write(lines.join('\n'));
}
function printBufferPrompt(dirtyTestFiles, rootDir) {
  const sep = (0, _base.separator)();
  process.stdout.write('\x1Bc');
  process.stdout.write(`${sep}\n`);
  if (dirtyTestFiles.size === 0) {
    process.stdout.write(`${_utilsBundle.colors.dim('Waiting for file changes. Press')} ${_utilsBundle.colors.bold('q')} ${_utilsBundle.colors.dim('to quit or')} ${_utilsBundle.colors.bold('h')} ${_utilsBundle.colors.dim('for more options.')}\n\n`);
    return;
  }
  process.stdout.write(`${_utilsBundle.colors.dim(`${dirtyTestFiles.size} test ${dirtyTestFiles.size === 1 ? 'file' : 'files'} changed:`)}\n\n`);
  for (const file of dirtyTestFiles) process.stdout.write(` · ${_path.default.relative(rootDir, file)}\n`);
  process.stdout.write(`\n${_utilsBundle.colors.dim(`Press`)} ${_utilsBundle.colors.bold('enter')} ${_utilsBundle.colors.dim('to run')}, ${_utilsBundle.colors.bold('q')} ${_utilsBundle.colors.dim('to quit or')} ${_utilsBundle.colors.bold('h')} ${_utilsBundle.colors.dim('for more options.')}\n\n`);
}
function printPrompt() {
  const sep = (0, _base.separator)();
  process.stdout.write(`
${sep}
${_utilsBundle.colors.dim('Waiting for file changes. Press')} ${_utilsBundle.colors.bold('enter')} ${_utilsBundle.colors.dim('to run tests')}, ${_utilsBundle.colors.bold('q')} ${_utilsBundle.colors.dim('to quit or')} ${_utilsBundle.colors.bold('h')} ${_utilsBundle.colors.dim('for more options.')}
`);
}
async function toggleShowBrowser() {
  if (!showBrowserServer) {
    showBrowserServer = new _playwrightServer.PlaywrightServer({
      mode: 'extension',
      path: '/' + (0, _utils.createGuid)(),
      maxConnections: 1
    });
    connectWsEndpoint = await showBrowserServer.listen();
    process.stdout.write(`${_utilsBundle.colors.dim('Show & reuse browser:')} ${_utilsBundle.colors.bold('on')}\n`);
  } else {
    var _showBrowserServer;
    await ((_showBrowserServer = showBrowserServer) === null || _showBrowserServer === void 0 ? void 0 : _showBrowserServer.close());
    showBrowserServer = undefined;
    connectWsEndpoint = undefined;
    process.stdout.write(`${_utilsBundle.colors.dim('Show & reuse browser:')} ${_utilsBundle.colors.bold('off')}\n`);
  }
}