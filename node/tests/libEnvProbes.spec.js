// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// The version-guarded Theming/Localization probes shipped in
// app/webapp/core/Lib.js (getThemingModule / getTheme / getLocale) - the
// single implementation behind Component.init's S_UI5 block, the devtools
// Inspect report and the THEMING global target in core/actions/ControlCall.
// Loaded with a seeded sap.ui.require / sap.ui.getCore, so the modern
// (1.118+) branch and the 1.71 Configuration fallback both run for real.

function libWithUi(ui) {
  return loadLib({ sap: { ui } });
}

test.describe("getThemingModule (lazy probe, rule 12)", () => {
  test("hands back the module where the release ships it", () => {
    const Theming = { setTheme: () => {} };
    const { Lib } = libWithUi({
      require: (name) =>
        name === "sap/ui/core/Theming" ? Theming : undefined,
    });
    expect(Lib.getThemingModule()).toBe(Theming);
  });

  test("answers null on the 1.71 floor instead of throwing", () => {
    const { Lib } = libWithUi({ require: () => undefined });
    expect(Lib.getThemingModule()).toBe(null);
  });
});

test.describe("getTheme (Theming since 1.118, Configuration before)", () => {
  test("prefers the Theming module and never asks the core", () => {
    const { Lib } = libWithUi({
      require: (name) =>
        name === "sap/ui/core/Theming"
          ? { getTheme: () => "sap_horizon" }
          : undefined,
      getCore: () => {
        throw new Error("must not fall back when Theming answers");
      },
    });
    expect(Lib.getTheme()).toBe("sap_horizon");
  });

  test("falls back to the Configuration on the 1.71 floor", () => {
    const { Lib } = libWithUi({
      require: () => undefined,
      getCore: () => ({
        getConfiguration: () => ({ getTheme: () => "sap_fiori_3" }),
      }),
    });
    expect(Lib.getTheme()).toBe("sap_fiori_3");
  });

  test("answers empty on a bare bootstrap", () => {
    const { Lib } = libWithUi({ require: () => undefined });
    expect(Lib.getTheme()).toBe("");
  });

  test("logs and answers empty when the probe throws", () => {
    const { Lib, sandbox } = libWithUi({
      require: () => undefined,
      getCore: () => {
        throw new Error("boom");
      },
    });
    expect(Lib.getTheme()).toBe("");
    expect(sandbox.z2ui5.errors.length).toBe(1);
    expect(sandbox.z2ui5.errors[0].message).toContain("theme");
  });
});

test.describe("getLocale (Localization since 1.118, Configuration before)", () => {
  test("prefers the Localization module", () => {
    const { Lib } = libWithUi({
      require: (name) =>
        name === "sap/base/i18n/Localization"
          ? { getLanguage: () => "en", getRTL: () => false }
          : undefined,
    });
    expect(Lib.getLocale()).toEqual({ language: "en", rtl: false });
  });

  test("falls back to the Configuration on the 1.71 floor", () => {
    const { Lib } = libWithUi({
      require: () => undefined,
      getCore: () => ({
        getConfiguration: () => ({
          getLanguage: () => "ar",
          getRTL: () => true,
        }),
      }),
    });
    expect(Lib.getLocale()).toEqual({ language: "ar", rtl: true });
  });

  test("answers the neutral shape on a bare bootstrap", () => {
    const { Lib } = libWithUi({ require: () => undefined });
    expect(Lib.getLocale()).toEqual({ language: "", rtl: false });
  });
});
