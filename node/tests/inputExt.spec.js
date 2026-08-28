// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/InputExt.js: a sap.m.Input whose inner <input> carries a bindable HTML
// `type`. The contract under test:
//   - the attribute lands on the FOCUS dom ref (the inner <input>), never on
//     the control root, and it survives every re-render because the control
//     writes it itself
//   - setInputType does not invalidate: a bound type is a DOM write, not a
//     re-render of the input and its suggestion popup
//   - clearing the property restores the type sap.m.Input rendered, so a
//     Password field does not silently become a visible one
//   - a value that is not an HTML input type a text field supports is logged
//     (once) and ignored - "log, never throw" (AGENTS.md rule 10)
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

  // `renderedType` is the type sap.m.Input itself put on the inner <input>;
  // null stands for a control that has no DOM yet.
  function makeInstance(renderedType = "text") {
    const inst = new InputExt();
    const props = { inputType: "" };
    inst.invalidations = 0;
    inst.getInputType = () => props.inputType;
    inst.setProperty = (name, value, suppressInvalidate) => {
      props[name] = value;
      if (!suppressInvalidate) inst.invalidations++;
    };
    inst.dom = renderedType === null ? null : fakeInput(renderedType);
    inst.getFocusDomRef = () => inst.dom;
    return inst;
  }

  return { makeInstance, errors };
}

// the inner <input> - only the three attribute methods the control uses
function fakeInput(type) {
  const attrs = {};
  if (type !== null) attrs.type = type;
  return {
    get type() {
      return "type" in attrs ? attrs.type : null;
    },
    getAttribute: (name) => (name in attrs ? attrs[name] : null),
    setAttribute: (name, value) => {
      attrs[name] = String(value);
    },
    removeAttribute: (name) => {
      delete attrs[name];
    },
  };
}

test("the rendering writes the type onto the inner input", () => {
  const { makeInstance } = load();
  const input = makeInstance();

  input.setProperty("inputType", "color");
  input.onAfterRendering();

  expect(input.baseAfterRendering).toBe(1);
  expect(input.dom.type).toBe("color");
});

test("setInputType writes the DOM directly and does not invalidate", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  expect(input.setInputType("range")).toBe(input);

  expect(input.dom.type).toBe("range");
  expect(input.invalidations).toBe(0);
});

test("an ABAP caller's casing and padding reach the browser normalized", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  input.setInputType("  DATETIME-LOCAL ");

  expect(input.dom.type).toBe("datetime-local");
});

test("clearing the type restores what sap.m.Input rendered", () => {
  const { makeInstance } = load();
  // a sap.m.Input with type="Password" renders type="password"
  const input = makeInstance("password");
  input.onAfterRendering();

  input.setInputType("search");
  expect(input.dom.type).toBe("search");

  input.setInputType("");
  expect(input.dom.type).toBe("password");
});

test("a re-render re-applies the type onto the new DOM", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.setInputType("month");

  // UI5 threw the old DOM away and rendered a fresh inner <input>
  input.dom = fakeInput("text");
  input.onAfterRendering();

  expect(input.dom.type).toBe("month");
});

test("a control without DOM applies its type on the next rendering", () => {
  const { makeInstance } = load();
  const input = makeInstance(null);

  input.setInputType("week");
  expect(input.dom).toBe(null);

  input.dom = fakeInput("text");
  input.onAfterRendering();
  expect(input.dom.type).toBe("week");
});

test("a type no text field supports is logged once and ignored", () => {
  const { makeInstance, errors } = load();
  const input = makeInstance("password");
  input.onAfterRendering();

  // writing a value into a file field throws, so the control refuses it
  input.setInputType("file");

  expect(input.dom.type).toBe("password");
  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("file");

  // every rendering re-applies the property; the log must not fill up
  input.onAfterRendering();
  input.onAfterRendering();
  expect(errors).toHaveLength(1);
});

test("every HTML type a text field supports is accepted", () => {
  const { makeInstance, errors } = load();
  const types = [
    "color",
    "date",
    "datetime-local",
    "email",
    "month",
    "number",
    "password",
    "range",
    "search",
    "tel",
    "text",
    "time",
    "url",
    "week",
  ];

  for (const type of types) {
    const input = makeInstance();
    input.setInputType(type);
    expect(input.dom.type).toBe(type);
  }
  expect(errors).toEqual([]);
});
