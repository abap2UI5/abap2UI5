// @ts-check
const { test, expect } = require("@playwright/test");
const { loadEnv } = require("./loadLibModule");

// The version-guarded Theming/Localization probes shipped in
// app/webapp/core/Env.js (getThemingModule / getTheme / getLocale) - the
// single implementation behind Component.init's S_UI5 block, the devtools
// Inspect report and the THEMING global target in core/actions/ControlCall.
// Loaded with a seeded sap.ui.require / sap.ui.getCore, so the modern
// (1.118+) branch and the 1.71 Configuration fallback both run for real.

function libWithUi(ui) {
  return loadEnv({ sap: { ui } });
}

test.describe("getThemingModule (lazy probe, rule 12)", () => {
  test("hands back the module where the release ships it", () => {
    const Theming = { setTheme: () => {} };
    const { Env } = libWithUi({
      require: (name) =>
        name === "sap/ui/core/Theming" ? Theming : undefined,
    });
    expect(Env.getThemingModule()).toBe(Theming);
  });

  test("answers null on the 1.71 floor instead of throwing", () => {
    const { Env } = libWithUi({ require: () => undefined });
    expect(Env.getThemingModule()).toBe(null);
  });
});

test.describe("getTheme (Theming since 1.118, Configuration before)", () => {
  test("prefers the Theming module and never asks the core", () => {
    const { Env } = libWithUi({
      require: (name) =>
        name === "sap/ui/core/Theming"
          ? { getTheme: () => "sap_horizon" }
          : undefined,
      getCore: () => {
        throw new Error("must not fall back when Theming answers");
      },
    });
    expect(Env.getTheme()).toBe("sap_horizon");
  });

  test("falls back to the Configuration on the 1.71 floor", () => {
    const { Env } = libWithUi({
      require: () => undefined,
      getCore: () => ({
        getConfiguration: () => ({ getTheme: () => "sap_fiori_3" }),
      }),
    });
    expect(Env.getTheme()).toBe("sap_fiori_3");
  });

  test("answers empty on a bare bootstrap", () => {
    const { Env } = libWithUi({ require: () => undefined });
    expect(Env.getTheme()).toBe("");
  });

  test("logs and answers empty when the probe throws", () => {
    const { Env, state } = libWithUi({
      require: () => undefined,
      getCore: () => {
        throw new Error("boom");
      },
    });
    expect(Env.getTheme()).toBe("");
    expect(state.errors.length).toBe(1);
    expect(state.errors[0].message).toContain("theme");
  });
});

test.describe("getLocale (Localization since 1.118, Configuration before)", () => {
  test("prefers the Localization module", () => {
    const { Env } = libWithUi({
      require: (name) =>
        name === "sap/base/i18n/Localization"
          ? { getLanguage: () => "en", getRTL: () => false }
          : undefined,
    });
    expect(Env.getLocale()).toEqual({ language: "en", rtl: false });
  });

  test("falls back to the Configuration on the 1.71 floor", () => {
    const { Env } = libWithUi({
      require: () => undefined,
      getCore: () => ({
        getConfiguration: () => ({
          getLanguage: () => "ar",
          getRTL: () => true,
        }),
      }),
    });
    expect(Env.getLocale()).toEqual({ language: "ar", rtl: true });
  });

  test("answers the neutral shape on a bare bootstrap", () => {
    const { Env } = libWithUi({ require: () => undefined });
    expect(Env.getLocale()).toEqual({ language: "", rtl: false });
  });
});
