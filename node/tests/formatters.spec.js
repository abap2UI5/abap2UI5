// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the app-supplied formatter registry in the real
// app/webapp/core/Formatters.js (loaded via a stubbed sap.ui.define).
// The registry backs client->register_formatter: response T_FORMATTER
// entries are compiled into z2ui5.fmt.<name> before views are created.

function load() {
  const errors = [];
  const Lib = { logError: (...a) => errors.push(a) };
  const { module } = loadModule("core/Formatters.js", {
    deps: { "z2ui5/core/Lib": Lib },
  });
  return { Formatters: module, errors };
}

test.describe("Formatters registry", () => {
  test("compiles a function expression and exposes it on fmt", () => {
    const { Formatters } = load();
    Formatters.register("weightState", "(v) => (v < 1 ? 'Success' : 'Error')");
    expect(Formatters.fmt.weightState(0.2)).toBe("Success");
    expect(Formatters.fmt.weightState(21)).toBe("Error");
  });

  test("registerAll takes the raw T_FORMATTER response rows", () => {
    const { Formatters } = load();
    Formatters.registerAll([
      { NAME: "upper", JS: "(s) => String(s).toUpperCase()" },
      { NAME: "noop", JS: "(s) => s" },
    ]);
    expect(Formatters.fmt.upper("abc")).toBe("ABC");
    expect(Formatters.fmt.noop(1)).toBe(1);
    Formatters.registerAll(undefined); // a response without formatters
  });

  test("re-registering replaces per name, same source is a no-op", () => {
    const { Formatters } = load();
    Formatters.register("f", "() => 1");
    const first = Formatters.fmt.f;
    Formatters.register("f", "() => 1");
    expect(Formatters.fmt.f).toBe(first); // cached, not recompiled
    Formatters.register("f", "() => 2");
    expect(Formatters.fmt.f()).toBe(2);
  });

  test("rejects a body that is not a function expression", () => {
    const { Formatters, errors } = load();
    Formatters.register("bad", "42");
    Formatters.register("broken", "() => {");
    expect(Formatters.fmt.bad).toBeUndefined();
    expect(Formatters.fmt.broken).toBeUndefined();
    expect(errors).toHaveLength(2);
  });
});
