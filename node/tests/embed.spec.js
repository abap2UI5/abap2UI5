// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// core/Embed.js: how the frontend is put into a host. The control
// (z2ui5.embed.Container) only loads the bundle and renders what create( )
// hands back - which component, with which component data, in which
// container is decided here, for every host alike.

// what the bundle's z2ui5/embed module knows about the installation
const INSTALLATION = {
  componentName: "z2ui5.embed.frontend",
  componentData: {
    nodePath: "/sap/bc/z2ui5",
    ccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_cci",
    cccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_ccc",
  },
};

function load({ owner = null, createFails = false, noSheets = false } = {}) {
  const created = [];
  const containers = [];
  const head = [];
  const adopted = [];
  const Component = {
    create: (settings) => {
      created.push(settings);
      return createFails
        ? Promise.reject(new Error("no manifest"))
        : Promise.resolve({ id: `component${created.length}` });
    },
    getOwnerComponentFor: () => owner,
  };
  function ComponentContainer(settings) {
    containers.push(settings);
    this.settings = settings;
  }
  class CSSStyleSheet {
    replaceSync(text) {
      if (noSheets) throw new Error("not supported");
      this.text = text;
    }
  }
  const document = {
    head: { appendChild: (node) => head.push(node) },
    createElement: (tag) => ({ tag }),
    getElementById: (id) => head.find((node) => node.id === id) || null,
    get adoptedStyleSheets() {
      return adopted;
    },
    set adoptedStyleSheets(list) {
      adopted.splice(0, adopted.length, ...list);
    },
  };
  const { module: Embed } = loadModule("core/Embed.js", {
    deps: {
      "sap/ui/core/Component": Component,
      "sap/ui/core/ComponentContainer": ComponentContainer,
    },
    sandbox: { document, CSSStyleSheet },
  });
  return { Embed, created, containers, head, adopted };
}

test.describe("startup parameters", () => {
  test("one array of values per name, sorted, the class as app_start", () => {
    const { Embed } = load();
    expect(
      JSON.stringify(
        Embed.startupParameters(
          { plant: ["1000", "2000"], matnr: 4711 },
          "ZCL_X",
        ),
      ),
    ).toBe('{"matnr":["4711"],"plant":["1000","2000"],"app_start":["ZCL_X"]}');
  });

  test("no value is no parameter, an object goes over as JSON", () => {
    const { Embed } = load();
    expect(
      Embed.startupParameters(
        { a: null, b: undefined, c: [null, "x"], d: { k: 1 }, e: [] },
        "",
      ),
    ).toEqual({ c: ["x"], d: ['{"k":1}'] });
  });

  test("an app_start among the params never names the class", () => {
    const { Embed } = load();
    expect(
      Embed.startupParameters({ app_start: "ZCL_OTHER" }, "ZCL_X"),
    ).toEqual({
      app_start: ["ZCL_X"],
    });
    // no class from the host: the backend reads it from the page's URL
    expect(Embed.startupParameters({ app_start: "ZCL_OTHER" }, "")).toEqual({});
  });
});

test.describe("component data", () => {
  test("the installation's settings, the endpoint and what the host set", () => {
    const { Embed } = load();
    expect(
      Embed.componentData(
        {
          app: "ZCL_X",
          endpoint: "https://host/sap/bc/z2ui5",
          params: { a: 1 },
        },
        INSTALLATION,
      ),
    ).toEqual({
      ...INSTALLATION.componentData,
      endpoint: "https://host/sap/bc/z2ui5",
      startupParameters: { a: ["1"], app_start: ["ZCL_X"] },
    });
  });

  test("a page of the app's own: ownsPage, and no startup parameters without a class", () => {
    const { Embed } = load();
    const data = Embed.componentData(
      { app: "", endpoint: "https://host/sap/bc/z2ui5", ownsPage: true },
      INSTALLATION,
    );
    expect(data.ownsPage).toBe(true);
    expect("startupParameters" in data).toBe(false);
    // ... and the installation's own object is not written to
    expect("ownsPage" in INSTALLATION.componentData).toBe(false);
  });

  test("ownsPage only when the host set it", () => {
    const { Embed } = load();
    const data = Embed.componentData(
      { app: "ZCL_X", endpoint: "/e", ownsPage: false },
      INSTALLATION,
    );
    expect("ownsPage" in data).toBe(false);
  });
});

test.describe("create", () => {
  test("a component under the bundle's second name, in a container that owns it", async () => {
    const { Embed, created, containers } = load();
    const app = await Embed.create(
      { app: "ZCL_X", endpoint: "/sap/bc/z2ui5", host: {} },
      INSTALLATION,
    );
    expect(created.length).toBe(1);
    expect(created[0].name).toBe("z2ui5.embed.frontend");
    expect(created[0].manifest).toBe(true);
    expect(created[0].handleValidation).toBe(true);
    expect(created[0].componentData.startupParameters).toEqual({
      app_start: ["ZCL_X"],
    });
    expect(containers).toEqual([
      {
        lifecycle: "Container",
        propagateModel: false,
        width: "100%",
        height: "100%",
        component: { id: "component1" },
      },
    ]);
    expect(app.settings).toBe(containers[0]);
  });

  test("created in the host's owner component", async () => {
    const ran = [];
    const owner = {
      runAsOwner: (fn) => {
        ran.push("owner");
        return fn();
      },
    };
    const { Embed, created } = load({ owner });
    await Embed.create(
      { app: "ZCL_X", endpoint: "/e", host: {} },
      INSTALLATION,
    );
    expect(ran).toEqual(["owner"]);
    expect(created.length).toBe(1);
  });

  test("an inactive owner does not keep the app from starting", async () => {
    const owner = {
      runAsOwner: () => {
        throw new Error("inactive");
      },
    };
    const { Embed, created } = load({ owner });
    await Embed.create(
      { app: "ZCL_X", endpoint: "/e", host: {} },
      INSTALLATION,
    );
    expect(created.length).toBe(1);
  });

  test("a component that cannot be created fails the start, and makes no container", async () => {
    const { Embed, containers } = load({ createFails: true });
    // caught by hand: the promise is the module's realm's, not the spec's
    const reason = await Embed.create(
      { app: "ZCL_X", endpoint: "/e", host: {} },
      INSTALLATION,
    ).then(
      () => null,
      (e) => e,
    );
    expect(reason && reason.message).toBe("no manifest");
    expect(containers).toEqual([]);
  });
});

test.describe("the style of the area", () => {
  const RULE =
    ".z2ui5EmbedContainer .sapMShell.sapMShellAppWidthLimited .sapMShellCentralBox";

  test("one constructed stylesheet per page, however many apps start", async () => {
    const { Embed, adopted, head } = load();
    await Embed.create({ app: "A", endpoint: "/e" }, INSTALLATION);
    await Embed.create({ app: "B", endpoint: "/e" }, INSTALLATION);
    expect(adopted.length).toBe(1);
    expect(adopted[0].text).toContain(RULE);
    // only the marker went into the head - no <style> element
    expect(head.map((node) => node.tag)).toEqual(["meta"]);
  });

  test("a <style> element where the browser constructs no stylesheet", async () => {
    const { Embed, adopted, head } = load({ noSheets: true });
    await Embed.create({ app: "A", endpoint: "/e" }, INSTALLATION);
    expect(adopted.length).toBe(0);
    expect(head.map((node) => node.tag)).toEqual(["meta", "style"]);
    expect(head[1].textContent).toContain(RULE);
  });
});
