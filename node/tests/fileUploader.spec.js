// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/FileUploader.js: wraps sap.ui.unified.FileUploader plus an optional
// Upload button; the chosen file is read as a base64 data URL into `value`
// and handed to the backend via the `upload` event. Under test: the two
// modes (button vs. direct upload), the pending-file plumbing through the
// real Lib.readFileAsDataURL, and the destroyed-guard of that read.

// FileReader stub for the REAL Lib.readFileAsDataURL: records instances so
// a spec can finish the read by hand (or never, for the destroy case).
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
    // the browser's own failure mode for a file that is picked but cannot be
    // read (NotReadableError: moved, unmounted, permission withdrawn)
    fail() {
      this.error = new Error("NotReadableError");
      this.onerror();
    }
  }
  return { readers, FakeFileReader };
}

function load() {
  const { readers, FakeFileReader } = makeFileReaderStub();
  // The real Lib (readFileAsDataURL, isDestroyed) with the FileReader global
  // stubbed inside Lib's own module sandbox.
  const { Lib, sandbox } = loadLib({ FileReader: FakeFileReader });

  class Button {
    constructor(settings) {
      this.settings = settings;
      this.enabled = settings.enabled;
      this.text = settings.text;
      this.destroyed = false;
    }
    setEnabled(v) {
      this.enabled = v;
    }
    setText(v) {
      this.text = v;
    }
    destroy() {
      this.destroyed = true;
    }
  }
  class InnerUploader {
    constructor(settings) {
      this.settings = settings;
    }
    getProperty(name) {
      return this.settings[name];
    }
  }
  // The per-render property sync (_syncControls) pushes every value through
  // the UI5 setters; the stub routes them back into `settings`.
  for (const name of [
    "tooltip",
    "icon",
    "iconOnly",
    "buttonOnly",
    "buttonText",
    "style",
    "fileType",
    "visible",
    "multiple",
    "enabled",
    "value",
    "placeholder",
  ]) {
    const setter = `set${name[0].toUpperCase()}${name.slice(1)}`;
    InnerUploader.prototype[setter] = function (v) {
      this.settings[name] = v;
    };
  }
  class HBox {
    constructor() {
      this.items = [];
      this.destroyed = false;
    }
    addItem(item) {
      this.items.push(item);
      return this;
    }
    destroy() {
      this.destroyed = true;
    }
  }

  const { module: FileUploaderDef } = loadModule("cc/FileUploader.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "sap/m/Button": Button,
      "sap/ui/unified/FileUploader": InnerUploader,
      "sap/m/HBox": HBox,
      "z2ui5/core/Lib": Lib,
    },
  });

  function makeInstance(props = {}) {
    const inst = Object.create(FileUploaderDef);
    inst._props = {
      value: "",
      path: "",
      tooltip: "",
      fileType: "",
      placeholder: "",
      buttonText: "",
      style: "",
      uploadButtonText: "Upload",
      enabled: true,
      icon: "sap-icon://browse-folder",
      iconOnly: false,
      buttonOnly: false,
      multiple: false,
      visible: true,
      checkDirectUpload: false,
      ...props,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.uploads = 0;
    inst.fireUpload = () => inst.uploads++;
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    return inst;
  }

  const render = (inst) =>
    FileUploaderDef.renderer.render({ renderControl() {} }, inst);

  // A change/uploadComplete event as the inner FileUploader fires it.
  const changeEvent = (uploader, file) => ({
    getParameter: (name) => (name === "files" ? (file ? [file] : []) : null),
    getSource: () => uploader,
  });

  return {
    makeInstance,
    render,
    changeEvent,
    readers,
    state: sandbox.z2ui5,
  };
}

test("button mode renders uploader + Upload button, disabled while no file", () => {
  const { makeInstance, render } = load();
  const inst = makeInstance();

  render(inst);

  expect(inst._oHBox.items).toEqual([inst.oFileUploader, inst.oUploadButton]);
  expect(inst.oFileUploader.settings.uploadOnChange).toBe(false);
  expect(inst.oUploadButton.enabled).toBe(false);
});

test("selecting a file stores the path and enables the Upload button", () => {
  const { makeInstance, render, changeEvent } = load();
  const inst = makeInstance();
  render(inst);

  inst.oFileUploader.settings.value = "photo.png";
  inst.oFileUploader.settings.change(
    changeEvent(inst.oFileUploader, { name: "photo.png" }),
  );

  expect(inst._props.path).toBe("photo.png");
  expect(inst.oUploadButton.enabled).toBe(true);
});

test("clearing the selection disables the Upload button again", () => {
  const { makeInstance, render, changeEvent } = load();
  const inst = makeInstance();
  render(inst);

  inst.oFileUploader.settings.value = "";
  inst.oFileUploader.settings.change(changeEvent(inst.oFileUploader, null));

  expect(inst.oUploadButton.enabled).toBe(false);
});

test("pressing Upload reads the pending file and fires upload with the data URL", () => {
  const { makeInstance, render, changeEvent, readers } = load();
  const inst = makeInstance();
  render(inst);

  inst.oFileUploader.settings.value = "doc.txt";
  inst.oFileUploader.settings.change(
    changeEvent(inst.oFileUploader, { name: "doc.txt" }),
  );
  inst.oUploadButton.settings.press();
  readers[0].finish();

  expect(inst._props.value).toBe("data:mock;base64,doc.txt");
  expect(inst.uploads).toBe(1);
});

test("with multiple, every selected file is read - one after the other", () => {
  const { makeInstance, render, readers, state } = load();
  const inst = makeInstance({ multiple: true });
  render(inst);
  const files = [{ name: "a.txt" }, { name: "b.txt" }, { name: "c.txt" }];
  // the upload event starts a roundtrip - what View1.eB does synchronously
  inst.fireUpload = () => {
    inst.uploads++;
    state.isBusy = true;
  };

  inst.oFileUploader.settings.value = "a.txt";
  inst.oFileUploader.settings.change({
    getParameter: (name) => (name === "files" ? files : null),
    getSource: () => inst.oFileUploader,
  });
  inst.oUploadButton.settings.press();

  // only files[0] was ever read before; now the rest wait in the queue
  expect(readers).toHaveLength(1);
  readers[0].finish();
  expect(inst._props.value).toBe("data:mock;base64,a.txt");
  expect(inst.uploads).toBe(1);
  expect(readers).toHaveLength(1);

  // the roundtrip lands: the next file follows
  state.isBusy = false;
  for (const fn of state.onAfterRendering) fn();
  readers[1].finish();
  expect(inst._props.value).toBe("data:mock;base64,b.txt");
  state.isBusy = false;
  for (const fn of state.onAfterRendering) fn();
  readers[2].finish();
  expect(inst._props.value).toBe("data:mock;base64,c.txt");
  expect(inst.uploads).toBe(3);
});

test("direct-upload mode renders no button and reads on uploadComplete", () => {
  const { makeInstance, render, changeEvent, readers } = load();
  const inst = makeInstance({ checkDirectUpload: true });
  render(inst);

  expect(inst.oUploadButton).toBe(null);
  expect(inst.oFileUploader.settings.uploadOnChange).toBe(true);

  // change only remembers the file ...
  inst.oFileUploader.settings.change(
    changeEvent(inst.oFileUploader, { name: "auto.bin" }),
  );
  expect(readers).toHaveLength(0);

  // ... uploadComplete performs the read and fires upload
  inst.oFileUploader.settings.value = "auto.bin";
  inst.oFileUploader.settings.uploadComplete(
    changeEvent(inst.oFileUploader, null),
  );
  readers[0].finish();

  expect(inst._props.path).toBe("auto.bin");
  expect(inst._props.value).toBe("data:mock;base64,auto.bin");
  expect(inst.uploads).toBe(1);
});

test("a read finishing after destroy neither writes value nor fires upload", () => {
  const { makeInstance, render, changeEvent, readers } = load();
  const inst = makeInstance();
  render(inst);
  inst.oFileUploader.settings.value = "late.txt";
  inst.oFileUploader.settings.change(
    changeEvent(inst.oFileUploader, { name: "late.txt" }),
  );
  inst.oUploadButton.settings.press();

  // torn down while the FileReader was busy (real Lib owner guard)
  inst._destroyed = true;
  readers[0].finish();

  expect(inst._props.value).toBe("");
  expect(inst.uploads).toBe(0);
});

// Create-once (the cc/CameraPicture pattern): the renderer must NOT rebuild
// the inner controls on every pass - that threw away the inner file input's
// selection and focus on every roundtrip that re-rendered the view.
test("re-rendering keeps the control set and syncs the new property values", () => {
  const { makeInstance, render } = load();
  const inst = makeInstance();
  render(inst);
  const firstBox = inst._oHBox;
  const firstUploader = inst.oFileUploader;

  inst._props.tooltip = "changed";
  render(inst);

  expect(inst._oHBox).toBe(firstBox);
  expect(firstBox.destroyed).toBe(false);
  expect(inst.oFileUploader).toBe(firstUploader);
  // ... but the property values still reach the inner control per render
  expect(firstUploader.settings.tooltip).toBe("changed");
});

// checkDirectUpload changes the STRUCTURE (upload button yes/no, and
// uploadOnChange is init-only on the inner control) - toggling it is the
// one case that rebuilds, destroying the previous set.
test("toggling checkDirectUpload rebuilds the control set", () => {
  const { makeInstance, render } = load();
  const inst = makeInstance();
  render(inst);
  const firstBox = inst._oHBox;
  expect(inst.oUploadButton).not.toBe(null);

  inst._props.checkDirectUpload = true;
  render(inst);

  expect(firstBox.destroyed).toBe(true);
  expect(inst._oHBox).not.toBe(firstBox);
  expect(inst.oUploadButton).toBe(null);
  expect(inst.oFileUploader.settings.uploadOnChange).toBe(true);
});

test("exit() destroys the owned HBox; before any render it is a no-op", () => {
  const { makeInstance, render } = load();
  const inst = makeInstance();
  render(inst);
  const box = inst._oHBox;

  inst.exit();
  expect(box.destroyed).toBe(true);

  makeInstance().exit();
});

// The sequential read queue is Lib.readFilesInTurn now (cc/UploadSetExt uses
// the same one). Two things it owes the control: a file that cannot be read
// must not take the rest of the selection down with it, and the selection
// must be read exactly once.
test("a file the reader cannot read does not stall the ones behind it", () => {
  const { makeInstance, render, readers, state } = load();
  const inst = makeInstance({ multiple: true });
  render(inst);
  const files = [{ name: "locked.txt" }, { name: "ok.txt" }];
  inst.fireUpload = () => {
    inst.uploads++;
    state.isBusy = true;
  };

  inst.oFileUploader.settings.change({
    getParameter: (name) => (name === "files" ? files : null),
    getSource: () => inst.oFileUploader,
  });
  inst.oUploadButton.settings.press();

  // the first read fails: nothing is uploaded, and the failure is reported
  readers[0].fail();
  expect(inst.uploads).toBe(0);
  // logError writes into the shared state (the real Lib's own log)
  expect(state.errors.map((e) => e.message)).toEqual([
    "FileUploader: FileReader failed",
  ]);
  // ... and the queue moves on right away - no roundtrip was started, so
  // there is none to wait for
  expect(readers).toHaveLength(2);
  readers[1].finish();
  expect(inst._props.value).toBe("data:mock;base64,ok.txt");
  expect(inst.uploads).toBe(1);
});

// The picked files used to stay remembered after the press, so pressing
// Upload again without picking anything queued the identical set a second
// time and every file reached the backend twice.
test("pressing Upload twice does not queue the same selection twice", () => {
  const { makeInstance, render, changeEvent, readers } = load();
  const inst = makeInstance();
  render(inst);

  inst.oFileUploader.settings.value = "doc.txt";
  inst.oFileUploader.settings.change(
    changeEvent(inst.oFileUploader, { name: "doc.txt" }),
  );
  inst.oUploadButton.settings.press();
  readers[0].finish();
  inst.oUploadButton.settings.press();

  expect(readers).toHaveLength(1);
  expect(inst.uploads).toBe(1);
});

// same for the direct-upload path, whose uploadComplete is what consumes the
// selection there
test("a second uploadComplete does not re-read the same file", () => {
  const { makeInstance, render, changeEvent, readers } = load();
  const inst = makeInstance({ checkDirectUpload: true });
  render(inst);

  inst.oFileUploader.settings.change(
    changeEvent(inst.oFileUploader, { name: "auto.bin" }),
  );
  inst.oFileUploader.settings.value = "auto.bin";
  inst.oFileUploader.settings.uploadComplete(
    changeEvent(inst.oFileUploader, null),
  );
  readers[0].finish();
  inst.oFileUploader.settings.uploadComplete(
    changeEvent(inst.oFileUploader, null),
  );

  expect(readers).toHaveLength(1);
  expect(inst.uploads).toBe(1);
});
