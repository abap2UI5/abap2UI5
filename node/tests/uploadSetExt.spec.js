// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/UploadSetExt.js: invisible companion of a sap.m.upload.UploadSet that
// reads every added file as a base64 data URL into bindable properties.
// Under test: the register/claim lifecycle (attach exactly once via the real
// Lib.claimOnce, unregister on exit), the file read plumbing, and the
// "log, never throw" guard around the attach calls.
function makeFileReaderStub() {
  const readers = [];
  class FakeFileReader {
    constructor() {
      readers.push(this);
    }
    readAsDataURL(file) {
      this.file = file;
    }
    finish() {
      this.result = "data:mock;base64," + this.file.name;
      this.onload();
    }
  }
  return { readers, FakeFileReader };
}

function load({ uploadSet } = {}) {
  const { readers, FakeFileReader } = makeFileReaderStub();
  // The real Lib: registerCallback/claimOnce/readFileAsDataURL are the
  // shipped ones; the shared state object is observable via sandbox.z2ui5.
  const { Lib, sandbox } = loadLib({ FileReader: FakeFileReader });
  const errors = [];
  Lib.logError = (m) => errors.push(m);

  const { module: UploadSetExtDef } = loadModule("cc/UploadSetExt.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": { byIdOfOwner: () => uploadSet ?? null },
    },
  });

  function makeInstance() {
    const inst = Object.create(UploadSetExtDef);
    inst._props = {
      uploadSetId: "upSet",
      fileData: "",
      fileName: "",
      mediaType: "",
      fileSize: "",
      removedFileName: "",
      checkInit: false,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.changes = 0;
    inst.removes = 0;
    inst.fireChange = () => inst.changes++;
    inst.fireRemove = () => inst.removes++;
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    return inst;
  }

  return { makeInstance, readers, errors, state: sandbox.z2ui5 };
}

// An UploadSet stub recording the attached handlers.
function uploadSetStub() {
  return {
    added: [],
    removed: [],
    attachAfterItemAdded(fn) {
      this.added.push(fn);
    },
    attachAfterItemRemoved(fn) {
      this.removed.push(fn);
    },
  };
}

const itemEvent = (item) => ({
  getParameter: (name) => (name === "item" ? item : null),
});

test("init registers the onAfterRendering hook, exit removes it", () => {
  const { makeInstance, state } = load();
  const inst = makeInstance();

  inst.init();
  expect(state.onAfterRendering).toHaveLength(1);

  inst.exit();
  expect(state.onAfterRendering).toHaveLength(0);
});

test("setControl claims the target exactly once", () => {
  const target = uploadSetStub();
  const { makeInstance } = load({ uploadSet: target });
  const inst = makeInstance();
  inst.init();

  // the hook fires once per roundtrip - the handlers must not stack up
  inst.setControl();
  inst.setControl();

  expect(inst._props.checkInit).toBe(true);
  expect(target.added).toHaveLength(1);
  expect(target.removed).toHaveLength(1);
});

test("an unresolved target leaves the claim open for a later render", () => {
  const { makeInstance } = load({ uploadSet: null });
  const inst = makeInstance();
  inst.init();

  inst.setControl();

  expect(inst._props.checkInit).toBe(false);
});

test("a throwing attach is logged, never thrown", () => {
  const { makeInstance, errors } = load({
    uploadSet: {
      attachAfterItemAdded() {
        throw new Error("no such event");
      },
    },
  });
  const inst = makeInstance();
  inst.init();

  inst.setControl();

  expect(errors.some((m) => m.includes("setControl: setup failed"))).toBe(true);
});

test("an added file lands in the bindable properties and fires change", () => {
  const { makeInstance, readers } = load();
  const inst = makeInstance();
  const file = { name: "report.pdf", type: "application/pdf", size: 1234 };

  inst.onItemAdded(itemEvent({ getFileObject: () => file }));
  readers[0].finish();

  expect(inst._props.fileData).toBe("data:mock;base64,report.pdf");
  expect(inst._props.fileName).toBe("report.pdf");
  expect(inst._props.mediaType).toBe("application/pdf");
  expect(inst._props.fileSize).toBe("1234");
  expect(inst.changes).toBe(1);
});

test("an item without a file object is ignored", () => {
  const { makeInstance, readers } = load();
  const inst = makeInstance();

  inst.onItemAdded(itemEvent({}));
  inst.onItemAdded(itemEvent(null));

  expect(readers).toHaveLength(0);
  expect(inst.changes).toBe(0);
});

test("a read finishing after destroy writes nothing (real Lib owner guard)", () => {
  const { makeInstance, readers } = load();
  const inst = makeInstance();
  inst.onItemAdded(
    itemEvent({ getFileObject: () => ({ name: "late.txt" }) }),
  );

  inst._destroyed = true;
  readers[0].finish();

  expect(inst._props.fileData).toBe("");
  expect(inst.changes).toBe(0);
});

test("a removed item reports its name and fires remove", () => {
  const { makeInstance } = load();
  const inst = makeInstance();

  inst.onItemRemoved(itemEvent({ getFileName: () => "old.txt" }));

  expect(inst._props.removedFileName).toBe("old.txt");
  expect(inst.removes).toBe(1);
});

test("a removed item without a name reports the empty string", () => {
  const { makeInstance } = load();
  const inst = makeInstance();

  inst.onItemRemoved(itemEvent(null));

  expect(inst._props.removedFileName).toBe("");
  expect(inst.removes).toBe(1);
});
