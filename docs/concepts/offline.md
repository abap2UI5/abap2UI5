# Offline queue

## The problem

Every event of an abap2UI5 app asks the server what happens next. When the
network goes for a moment - a warehouse aisle without signal, a lift, a
train, a laptop waking up - the event fails, and the user sees the error
overlay with Retry. For most screens that is right. For the screens that
capture data - a goods receipt, a count, a scan, a form filled in by the
road - it means the entry is gone, or the user waits at the shelf for the
signal to come back.

This concept does **not** make abap2UI5 an offline framework. "Offline is
out" stays true for the page: without a server there is no next view, and
no view the server has not sent can be rendered. What it adds is narrower:
an event the app names **waits** in the browser instead of failing, and is
sent once the backend can be reached again.

## What the first cut does

The app names the events that may wait, on the view that captures:

```abap
client->follow_up_action( val   = client->cs_event-offline_queue
                          t_arg = VALUE #( ( `Saved offline - &1 waiting` ) ( `SAVE` ) ) ).
```

Then, for those events only:

1. **A network failure keeps the request.** When the POST cannot reach the
   backend at all (the browser's `TypeError`, not a timeout, not an HTTP
   error), the request body as the frontend built it - event, arguments,
   model changes - is kept in `localStorage` under the endpoint's URL. The
   roundtrip ends without the overlay, and the toast says so in the app's
   words (`&1` is how many wait). The edits count as sent, so the next event
   does not carry them twice.
2. **The queue survives the tab.** A reload or a closed tab keeps it. The
   next start of the app that switches the queue on sends it.
3. **Back online, it is sent in order.** On the browser's `online` event (and
   on the next start) the requests go out one by one, each on the draft the
   previous answer left - the app sees them as events that arrived late, in
   the order they were made. The answers in between are read for their draft
   id only; the last one is rendered like any roundtrip.
4. **Every other event is untouched.** It fails as it always did, with the
   overlay and Retry.

Where it is: `app/webapp/core/Offline.js` (the store),
`Server.readHttp` / `Server.replayOffline` (keeping and sending),
`OFFLINE_QUEUE` in `core/actions/Browser.js` (the switch), the constant in
`z2ui5_if_client=>cs_event`, the fixture `node/srv/zcl_tst_offline` and the
specs `node/tests/offline.spec.js` and `node/tests/e2e/offline-queue.spec.js`.

## What it must not become

- **No second place where an app decides.** The browser keeps requests; it
  does not validate them, compute anything or show a view of its own. The
  backend decides what a late event means, exactly as it decides what a
  timely one means.
- **No silent loss.** A request that cannot be kept (storage refused, quota
  full) falls back to the overlay. A request the backend refuses on the way
  back stays in the queue with the rest behind it.
- **No offline page load in the framework.** Loading the page without a
  network needs UI5 and the frontend in a cache the browser controls - a
  service worker on the ICF node, or the mobile shell's own cache. That is a
  deployment question, not a framework one, and it is the second step below.

## What the app has to know

- A queued event arrives **late**. Stock, prices and locks may have moved;
  the app checks what it would check anyway and answers with a message when
  the entry no longer fits. The first cut sends nothing that tells a late
  event from a timely one - see the open questions.
- A queued event carries the **changes** the user made, not the whole form.
  A capture view that empties its fields after each SAVE (the usual shape)
  works as expected; a view whose fields depend on the answer to the
  previous event does not belong in the queue.
- **At most once, not at least once.** An entry leaves the queue when it is
  sent. If the page dies in that moment - a reload, a closed tab - after the
  request went out but before the answer came, the entry is gone from the
  queue whether or not the backend received it; it is never sent twice.
  Telling the two apart needs an id per event the backend can check (next
  step 2).
- **Stateful apps** (`set_session_stateful`) are out: the session the queue
  would be sent into is gone by the time it is sent.
- The queue is **per browser and per endpoint**, in the user's browser. A
  shared device sends what the previous user queued under the session of the
  next one; an app that runs on shared devices does not switch the queue on,
  or keys its data by user in the event arguments.

## Next steps, in order

1. **Real use on one capture screen** - the prototype as it is, in a
   development system, with the mobile shell or a phone browser. What breaks
   first decides the next step.
2. **Mark a late event.** A flag, the time the event was made and an id the
   backend can check for a second delivery, in the request (`S_FRONT`),
   readable through `client->get( )` - with the id, an entry can stay in the
   queue until its answer arrives (at least once, duplicates refused). A protocol change,
   so it goes into abap2UI5/protocol first.
3. **Load the page without a network** - for the mobile shell first, which
   controls its webview and can cache UI5 and the frontend; a service worker
   on an ICF node is the harder half (scope, logon redirects, cache busting
   on upgrade).
4. **Show what waits.** A bindable count of queued events, so a view can
   show "3 entries waiting" without a toast.

## Open questions

- Does a capture screen need more than "wait and send in order" - for
  example, a list of what waits, with a way to discard one?
- Should a late event be refused by default after some age, and who sets it:
  the app, the exit, the user?
- Is `localStorage` enough (it is synchronous and small, a few MB), or does
  a queue of photos need IndexedDB?
- The documentation says abap2UI5 is online-only ("Offline is out", the
  mobile shell page). If this ships, those pages say what it covers and what
  it does not, in the same release.
