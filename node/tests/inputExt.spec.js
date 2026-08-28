// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/InputExt.js: a sap.m.Input whose inner <input> carries a bindable HTML
// `inputmode`. The contract under test:
//   - the attribute lands on the FOCUS dom ref (the inner <input>), never on
//     the control root, and it survives every re-render because the control
//     writes it itself
//   - setInputMode does not invalidate: a bound mode is a DOM write, not a
//     re-render of the input and its suggestion popup
//   - with the property empty the control leaves the DOM exactly as
//     sap.m.Input rendered it - that is the whole "identical apart from
//     inputMode" claim
//   - a value that is not an inputmode keyword is logged (once) and ignored -
//     "log, never throw" (AGENTS.md rule 10)
function load() {
  const errors = [];
  // Base sap.m.Input stub: the control chains Input.prototype.onAfterRendering
  // and reuses sap.m.InputRenderer unchanged.
  function InputBase() {}
  InputBase.prototype.onAfterRendering = function () {
    this.baseAfterRendering = (this.baseAfterRendering || 0) + 1;
  };
  InputBase.extend = (_name, def) => {
    function Ctrl() {}
    Ctrl.prototype = Object.create(InputBase.prototype);
    Object.assign(Ctrl.prototype, def);
    return Ctrl;
  };

  const { module: InputExt } = loadModule("cc/InputExt.js", {
    deps: {
      "sap/m/Input": InputBase,
      "sap/m/InputRenderer": {},
      "z2ui5/core/Lib": { logError: (m) => errors.push(m) },
    },
  });

  // `rendered` is what sap.m.Input itself put on the inner <input>; null
  // stands for a control that has no DOM yet.
  function makeInstance(rendered = { type: "text" }) {
    const inst = new InputExt();
    const props = { inputMode: "" };
    inst.invalidations = 0;
    inst.getInputMode = () => props.inputMode;
    inst.setProperty = (name, value, suppressInvalidate) => {
      props[name] = value;
      if (!suppressInvalidate) inst.invalidations++;
    };
    inst.dom = rendered === null ? null : fakeInput(rendered);
    inst.getFocusDomRef = () => inst.dom;
    return inst;
  }

  return { makeInstance, errors };
}

// the inner <input> - only the three attribute methods the control uses
function fakeInput(attributes = {}) {
  const attrs = { ...attributes };
  return {
    attr: (name) => (name in attrs ? attrs[name] : null),
    getAttribute: (name) => (name in attrs ? attrs[name] : null),
    setAttribute: (name, value) => {
      attrs[name] = String(value);
    },
    removeAttribute: (name) => {
      delete attrs[name];
    },
  };
}

test("the rendering writes the mode onto the inner input", () => {
  const { makeInstance } = load();
  const input = makeInstance();

  input.setProperty("inputMode", "none");
  input.onAfterRendering();

  expect(input.baseAfterRendering).toBe(1);
  expect(input.dom.attr("inputmode")).toBe("none");
});

test("setInputMode writes the DOM directly and does not invalidate", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  expect(input.setInputMode("numeric")).toBe(input);

  expect(input.dom.attr("inputmode")).toBe("numeric");
  expect(input.invalidations).toBe(0);
});

test("an ABAP caller's casing and padding reach the browser normalized", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  input.setInputMode("  NUMERIC ");

  expect(input.dom.attr("inputmode")).toBe("numeric");
});

test("with the property empty the DOM stays what sap.m.Input rendered", () => {
  const { makeInstance } = load();
  // a sap.m.Input with type="Password" renders type="password" and no
  // inputmode of its own
  const input = makeInstance({ type: "password" });

  input.onAfterRendering();

  expect(input.dom.attr("type")).toBe("password");
  expect(input.dom.attr("inputmode")).toBe(null);
});

test("clearing the mode takes the attribute off again", () => {
  const { makeInstance } = load();
  const input = makeInstance({ type: "password" });
  input.onAfterRendering();

  input.setInputMode("none");
  expect(input.dom.attr("inputmode")).toBe("none");

  input.setInputMode("");

  expect(input.dom.attr("inputmode")).toBe(null);
  // the control never touched anything else
  expect(input.dom.attr("type")).toBe("password");
});

test("a mode the release rendered itself survives an empty property", () => {
  const { makeInstance } = load();
  // sap.m.Input renders no inputmode today; should a release start, an empty
  // property must leave that field alone rather than strip it
  const input = makeInstance({ type: "text", inputmode: "numeric" });

  input.onAfterRendering();

  expect(input.dom.attr("inputmode")).toBe("numeric");
});

test("a re-render re-applies the mode onto the new DOM", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.setInputMode("none");

  // UI5 threw the old DOM away and rendered a fresh inner <input>
  input.dom = fakeInput({ type: "text" });
  input.onAfterRendering();

  expect(input.dom.attr("inputmode")).toBe("none");
});

test("a control without DOM applies its mode on the next rendering", () => {
  const { makeInstance } = load();
  const input = makeInstance(null);

  input.setInputMode("decimal");
  expect(input.dom).toBe(null);

  input.dom = fakeInput({ type: "text" });
  input.onAfterRendering();

  expect(input.dom.attr("inputmode")).toBe("decimal");
});

test("a value that is not an inputmode keyword is logged once and ignored", () => {
  const { makeInstance, errors } = load();
  const input = makeInstance();
  input.onAfterRendering();

  // `numerical` is not a keyword - `numeric` is
  input.setInputMode("numerical");

  expect(input.dom.attr("inputmode")).toBe(null);
  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("numerical");

  // every rendering re-applies the property; the log must not fill up
  input.onAfterRendering();
  input.onAfterRendering();
  expect(errors).toHaveLength(1);
});

test("every inputmode keyword of the HTML standard is accepted", () => {
  const { makeInstance, errors } = load();
  const modes = [
    "decimal",
    "email",
    "none",
    "numeric",
    "search",
    "tel",
    "text",
    "url",
  ];

  for (const mode of modes) {
    const input = makeInstance();
    input.setInputMode(mode);
    expect(input.dom.attr("inputmode")).toBe(mode);
  }
  expect(errors).toEqual([]);
});
