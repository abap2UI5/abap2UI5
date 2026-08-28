// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/Timer.js (obsolete, replaced by cs_event-start_timer): fires `finished`
// `delayMS` after rendering, so the backend can drive a time-based roundtrip.
//
// The control is small and every one of its decisions is a way a timer goes
// wrong: it arms from the RENDERER (via the _pendingTimer flag) rather than
// from init, so a control that was never rendered never fires; a one-shot
// disarms itself before firing so a re-render cannot restart it; a repeating
// one re-arms itself after firing; and both re-check Lib.isDestroyed after
// the delay AND after fireFinished, because the event handler is exactly what
// tends to tear the view down.
//
// The clock is a stub rather than a real setTimeout: a spec that waits for
// wall-clock time is a spec that goes flaky on a loaded runner.
function load() {
  const clock = { pending: new Map(), next: 1 };
  const setTimeoutStub = (fn, delay) => {
    const id = clock.next++;
    clock.pending.set(id, { fn, delay });
    return id;
  };
  const clearTimeoutStub = (id) => clock.pending.delete(id);
  // Run every timer armed at this moment, once. A callback that arms a new
  // one (the repeating path) leaves it for the next tick, so a repeat cannot
  // spin forever inside one call.
  clock.tick = () => {
    const due = [...clock.pending.entries()];
    clock.pending.clear();
    for (const [, t] of due) t.fn();
    return due.map(([, t]) => t.delay);
  };

  const { module: TimerDef } = loadModule("cc/Timer.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": {
        isDestroyed: (o) => o._destroyed === true,
        renderInvisibleSpan: () => {},
      },
    },
    sandbox: { setTimeout: setTimeoutStub, clearTimeout: clearTimeoutStub },
  });

  function instance(props = {}) {
    const inst = Object.create(TimerDef);
    inst._props = { delayMS: 0, checkActive: true, checkRepeat: false, ...props };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst._destroyed = false;
    inst.fired = 0;
    inst.fireFinished = () => inst.fired++;
    // What the renderer does, without a RenderManager.
    inst.render = () => TimerDef.renderer.render({}, inst);
    return inst;
  }

  return { instance, clock };
}

test("nothing is armed until the control renders", () => {
  const { instance, clock } = load();
  const inst = instance();

  inst.onAfterRendering();
  expect(clock.pending.size).toBe(0);
  expect(inst.fired).toBe(0);

  inst.render();
  inst.onAfterRendering();
  expect(clock.pending.size).toBe(1);
});

test("the delay armed is the bound delayMS", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 2500 });

  inst.render();
  inst.onAfterRendering();

  expect(clock.tick()).toEqual([2500]);
  expect(inst.fired).toBe(1);
});

test("checkActive false: rendering arms nothing", () => {
  const { instance, clock } = load();
  const inst = instance({ checkActive: false });

  inst.render();
  inst.onAfterRendering();

  expect(clock.pending.size).toBe(0);
});

// A one-shot disarms itself BEFORE firing, so the re-render the roundtrip
// causes cannot start it again.
test("a one-shot fires once and clears checkActive", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 10 });

  inst.render();
  inst.onAfterRendering();
  clock.tick();

  expect(inst.fired).toBe(1);
  expect(inst.getProperty("checkActive")).toBe(false);

  inst.render();
  inst.onAfterRendering();
  expect(clock.pending.size).toBe(0);
  expect(inst.fired).toBe(1);
});

test("a repeating timer re-arms itself and keeps checkActive", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 5, checkRepeat: true });

  inst.render();
  inst.onAfterRendering();

  clock.tick();
  expect(inst.fired).toBe(1);
  expect(inst.getProperty("checkActive")).toBe(true);
  expect(clock.tick()).toEqual([5]);
  expect(inst.fired).toBe(2);
});

// The second rendering must not leave two timers running against one control.
test("re-arming clears the previous timer instead of stacking one on it", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 10, checkRepeat: true });

  inst.render();
  inst.onAfterRendering();
  inst.render();
  inst.onAfterRendering();

  expect(clock.pending.size).toBe(1);
  clock.tick();
  expect(inst.fired).toBe(1);
});

test("a control destroyed during the delay does not fire", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 10 });

  inst.render();
  inst.onAfterRendering();
  inst._destroyed = true;
  clock.tick();

  expect(inst.fired).toBe(0);
});

// fireFinished is what triggers the roundtrip, and the roundtrip is what
// tends to destroy the view - so the repeat path re-checks afterwards.
test("a repeating timer stops when the event handler destroys the control", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 10, checkRepeat: true });
  inst.fireFinished = () => {
    inst.fired++;
    inst._destroyed = true;
  };

  inst.render();
  inst.onAfterRendering();
  clock.tick();

  expect(inst.fired).toBe(1);
  expect(clock.pending.size).toBe(0);
});

test("exit clears a pending timer", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 10 });

  inst.render();
  inst.onAfterRendering();
  inst.exit();

  expect(clock.pending.size).toBe(0);
});

// onAfterRendering runs on every re-render (theme change, parent
// invalidation); only the one that follows a render with checkActive set
// arms anything.
test("_pendingTimer is consumed, so one render arms exactly one timer", () => {
  const { instance, clock } = load();
  const inst = instance({ delayMS: 10 });

  inst.render();
  inst.onAfterRendering();
  clock.pending.clear();
  inst.onAfterRendering();

  expect(clock.pending.size).toBe(0);
});
