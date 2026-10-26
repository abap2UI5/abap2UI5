// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, classEnv } = require("./loadLibModule");

// cc/HTMLFrame.js: an app's own HTML document in a sandboxed iframe, and the
// sapevent: links and forms in it as the `sapevent` event. The contract:
//   - a click on <a href="sapevent:action?query"> is cancelled and fired
//     with action and getdata; any other link is left to the browser
//   - every submit is cancelled; a form to a sapevent: action is fired
//     with its fields urlencoded - postdata for post, getdata for get -
//     the submitting button included; a form to anything else is logged
//   - the frame gets the content as srcdoc, sandboxed with allow-scripts
//     (WebKit calls no listener in a frame without it - the inherited CSP is
//     what keeps the document's script out, see the e2e) and without
//     allow-top-navigation; the listeners go on each document once
// The real browser behaviour - the srcdoc under the shipped CSP, a click
// inside the frame - is node/tests/e2e/html-frame.spec.js.
function load() {
  const errors = [];
  const Lib = { ...loadLib().Lib, logError: (m) => errors.push(m) };
  const { module: HTMLFrame } = loadModule("cc/HTMLFrame.js", {
    deps: {
      "z2ui5/core/Env": classEnv,
      "sap/ui/core/Control": {
        extend(_name, def) {
          function Ctrl() {}
          Object.assign(Ctrl.prototype, def);
          Object.assign(Ctrl, def.statics || {});
          Ctrl.renderer = def.renderer;
          return Ctrl;
        },
      },
      "z2ui5/core/Lib": Lib,
    },
    sandbox: { URLSearchParams },
  });

  function makeInstance(props = {}) {
    const inst = new HTMLFrame();
    const values = { content: "", width: "100%", height: "30rem", title: "", ...props };
    inst.getContent = () => values.content;
    inst.getWidth = () => values.width;
    inst.getHeight = () => values.height;
    inst.getTitle = () => values.title;
    inst.events = [];
    inst.fireSapevent = (p) => inst.events.push(p);
    inst.isDestroyed = () => false;
    return inst;
  }

  return { HTMLFrame, makeInstance, errors };
}

// an event of the frame's document: a click on `target`, or a submit
function domEvent(target, submitter) {
  return {
    target,
    submitter,
    prevented: false,
    preventDefault() {
      this.prevented = true;
    },
  };
}

function link(href) {
  const a = { getAttribute: (n) => (n === "href" ? href : null) };
  return { closest: (sel) => (sel === "a[href]" ? a : null) };
}

function form({ action, method = "post", elements = [] }) {
  return {
    tagName: "FORM",
    elements,
    getAttribute: (n) => ({ action, method })[n] ?? null,
  };
}

test("sapevent: addresses split into action and getdata; others are none", () => {
  const { HTMLFrame } = load();
  expect(HTMLFrame._parseSapevent("sapevent:go_repo?key=4711&x=1")).toEqual({
    action: "go_repo",
    getdata: "key=4711&x=1",
  });
  expect(HTMLFrame._parseSapevent(" SAPEVENT:refresh")).toEqual({
    action: "refresh",
    getdata: "",
  });
  expect(HTMLFrame._parseSapevent("https://github.com")).toBeNull();
  expect(HTMLFrame._parseSapevent(null)).toBeNull();
});

test("a sapevent: link is cancelled and fired; another link is the browser's", () => {
  const { makeInstance } = load();
  const inst = makeInstance();

  const e = domEvent(link("sapevent:show?key=1"));
  inst._onClick(e);
  expect(e.prevented).toBe(true);
  expect(inst.events).toEqual([{ action: "show", getdata: "key=1", postdata: "" }]);

  const other = domEvent(link("https://abapgit.org"));
  inst._onClick(other);
  expect(other.prevented).toBe(false);
  // a click on no link at all
  inst._onClick(domEvent({ closest: () => null }));
  expect(inst.events).toHaveLength(1);
});

test("a form posted to sapevent: fires its fields as postdata, the button included", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const submit = { name: "action", value: "commit", type: "submit" };
  const elements = [
    { name: "comment", value: "first & last", type: "text" },
    { name: "push", value: "X", type: "checkbox", checked: true },
    { name: "skip", value: "X", type: "checkbox", checked: false },
    { name: "off", value: "1", type: "text", disabled: true },
    { name: "", value: "nameless", type: "text" },
    submit,
  ];

  const e = domEvent(form({ action: "sapevent:commit_post", elements }), submit);
  inst._onSubmit(e);
  expect(e.prevented).toBe(true);
  expect(inst.events).toEqual([
    {
      action: "commit_post",
      getdata: "",
      postdata: "comment=first+%26+last&push=X&action=commit",
    },
  ]);
});

test("a form sent with get puts its fields into getdata", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const elements = [{ name: "filter", value: "zcl", type: "text" }];

  inst._onSubmit(domEvent(form({ action: "sapevent:search?page=2", method: "GET", elements })));
  expect(inst.events).toEqual([{ action: "search", getdata: "page=2&filter=zcl", postdata: "" }]);
});

test("a form to another address is cancelled and logged, not fired", () => {
  const { makeInstance, errors } = load();
  const inst = makeInstance();

  const e = domEvent(form({ action: "https://example.org/post" }));
  inst._onSubmit(e);
  expect(e.prevented).toBe(true);
  expect(inst.events).toEqual([]);
  expect(errors.join()).toContain("only sapevent: actions are");
});

test("the renderer writes a sandboxed frame, the content as srcdoc", () => {
  const { HTMLFrame, makeInstance } = load();
  const inst = makeInstance({ content: "<p>hi</p>", height: "40rem", title: "Repository" });
  const out = { attrs: {}, styles: {} };
  const rm = {
    openStart: (tag) => (out.tag = tag),
    attr: (n, v) => (out.attrs[n] = v),
    style: (n, v) => (out.styles[n] = v),
    openEnd: () => {},
    close: (tag) => (out.closed = tag),
  };

  HTMLFrame.renderer.render(rm, inst);
  expect(out.tag).toBe("iframe");
  expect(out.closed).toBe("iframe");
  expect(out.attrs.srcdoc).toBe("<p>hi</p>");
  expect(out.attrs.title).toBe("Repository");
  expect(out.attrs.sandbox.split(" ")).toContain("allow-same-origin");
  expect(out.attrs.sandbox.split(" ")).toContain("allow-forms");
  // WebKit calls no listener of a frame that forbids scripts - see the header
  expect(out.attrs.sandbox.split(" ")).toContain("allow-scripts");
  expect(out.attrs.sandbox.split(" ")).not.toContain("allow-top-navigation");
  expect(out.styles.height).toBe("40rem");
});

test("each document of the frame gets the listeners once; an unreachable one is logged", () => {
  const { makeInstance, errors } = load();
  const inst = makeInstance();
  const added = [];
  const doc = { addEventListener: (type, _fn, capture) => added.push(`${type}:${capture}`) };
  const frame = { contentDocument: doc };

  inst._wire(frame);
  inst._wire(frame);
  expect(added).toEqual(["click:true", "submit:true"]);

  const sealed = {
    get contentDocument() {
      throw new Error("SecurityError");
    },
  };
  inst._wire(sealed);
  expect(errors.join()).toContain("out of reach");
});
