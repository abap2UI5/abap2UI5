// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/InputExt.js: a sap.m.Input whose inner <input> carries a bindable HTML
// `type` and `inputmode`. The contract under test:
//   - both attributes land on the FOCUS dom ref (the inner <input>), never on
//     the control root, and they survive every re-render because the control
//     writes them itself
//   - the setters do not invalidate: a bound value is a DOM write, not a
//     re-render of the input and its suggestion popup
//   - clearing a property restores what sap.m.Input rendered, so a Password
//     field does not silently become a visible one
//   - a value the HTML attribute does not take is logged (once per property)
//     and ignored - "log, never throw" (AGENTS.md rule 10)
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
    const props = { inputType: "", inputMode: "" };
    inst.invalidations = 0;
    inst.getProperty = (name) => props[name];
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

test("the rendering writes both attributes onto the inner input", () => {
  const { makeInstance } = load();
  const input = makeInstance();

  input.setProperty("inputType", "search");
  input.setProperty("inputMode", "none");
  input.onAfterRendering();

  expect(input.baseAfterRendering).toBe(1);
  expect(input.dom.attr("type")).toBe("search");
  expect(input.dom.attr("inputmode")).toBe("none");
});

test("the setters write the DOM directly and do not invalidate", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  expect(input.setInputType("range")).toBe(input);
  expect(input.setInputMode("decimal")).toBe(input);

  expect(input.dom.attr("type")).toBe("range");
  expect(input.dom.attr("inputmode")).toBe("decimal");
  expect(input.invalidations).toBe(0);
});

test("an ABAP caller's casing and padding reach the browser normalized", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  input.setInputType("  DATETIME-LOCAL ");
  input.setInputMode(" NUMERIC ");

  expect(input.dom.attr("type")).toBe("datetime-local");
  expect(input.dom.attr("inputmode")).toBe("numeric");
});

test("clearing restores what sap.m.Input rendered", () => {
  const { makeInstance } = load();
  // a sap.m.Input with type="Password" renders type="password"
  const input = makeInstance({ type: "password" });
  input.onAfterRendering();

  input.setInputType("search");
  input.setInputMode("none");
  expect(input.dom.attr("type")).toBe("search");

  input.setInputType("");
  input.setInputMode("");

  expect(input.dom.attr("type")).toBe("password");
  // UI5 rendered no inputmode, so clearing takes the attribute off entirely
  expect(input.dom.attr("inputmode")).toBe(null);
});

test("a re-render re-applies both attributes onto the new DOM", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.setInputType("month");
  input.setInputMode("numeric");

  // UI5 threw the old DOM away and rendered a fresh inner <input>
  input.dom = fakeInput({ type: "text" });
  input.onAfterRendering();

  expect(input.dom.attr("type")).toBe("month");
  expect(input.dom.attr("inputmode")).toBe("numeric");
});

test("a control without DOM applies its values on the next rendering", () => {
  const { makeInstance } = load();
  const input = makeInstance(null);

  input.setInputType("week");
  input.setInputMode("none");
  expect(input.dom).toBe(null);

  input.dom = fakeInput({ type: "text" });
  input.onAfterRendering();

  expect(input.dom.attr("type")).toBe("week");
  expect(input.dom.attr("inputmode")).toBe("none");
});

test("a refused value is logged once per property and ignored", () => {
  const { makeInstance, errors } = load();
  const input = makeInstance({ type: "password" });
  input.onAfterRendering();

  // writing a value into a file field throws, so the control refuses it
  input.setInputType("file");
  // `numerical` is not an inputmode keyword - `numeric` is
  input.setInputMode("numerical");

  expect(input.dom.attr("type")).toBe("password");
  expect(input.dom.attr("inputmode")).toBe(null);
  expect(errors).toHaveLength(2);
  expect(errors[0]).toContain("inputType");
  expect(errors[1]).toContain("inputMode");

  // every rendering re-applies both properties; the log must not fill up
  input.onAfterRendering();
  input.onAfterRendering();
  expect(errors).toHaveLength(2);
});

test("the two properties are independent", () => {
  const { makeInstance } = load();
  const input = makeInstance();
  input.onAfterRendering();

  input.setInputMode("none");
  expect(input.dom.attr("type")).toBe("text");
  expect(input.dom.attr("inputmode")).toBe("none");

  input.setInputType("number");
  expect(input.dom.attr("type")).toBe("number");
  expect(input.dom.attr("inputmode")).toBe("none");
});

test("every keyword the HTML attributes take is accepted", () => {
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

  for (const type of types) {
    const input = makeInstance();
    input.setInputType(type);
    expect(input.dom.attr("type")).toBe(type);
  }
  for (const mode of modes) {
    const input = makeInstance();
    input.setInputMode(mode);
    expect(input.dom.attr("inputmode")).toBe(mode);
  }
  expect(errors).toEqual([]);
});
