// The developer tools' sessionStorage access - the opt-in switches, the
// remembered sub-view and the records carried across a page reload.
//
// Three modules used to carry their own copy of the same guarded read and
// write. sessionStorage throws in some embedded and privacy configurations,
// and a diagnostic tool must never be the thing that breaks the app: every
// access here is wrapped, a failed read answers the "nothing stored" value
// and a failed write simply does not persist. sessionStorage rather than
// localStorage on purpose - a setting survives a reload but not the tab,
// so a developer cannot leave payload recording on for a colleague by
// accident.
//
// Zero dependencies, like devtools/Format.js: devtools/Console.js and
// devtools/Recorder.js are the bottom of the devtools/ dependency graph,
// and this module sits below them.
sap.ui.define([], () => {
  "use strict";

  // The stored string, "" when nothing is stored or storage is unavailable.
  function read(key) {
    try {
      return window.sessionStorage?.getItem(key) || "";
    } catch {
      return "";
    }
  }

  function write(key, value) {
    try {
      window.sessionStorage?.setItem(key, value);
    } catch {
      // storage unavailable - the value then does not persist
    }
  }

  function remove(key) {
    try {
      window.sessionStorage?.removeItem(key);
    } catch {
      // storage unavailable - nothing was stored to begin with
    }
  }

  // A switch is stored as "X" (the ABAP flag) and absent when off, so a
  // storage that lost the key reads as the default.
  function readFlag(key) {
    return read(key) === "X";
  }

  function writeFlag(key, enabled) {
    if (enabled) {
      write(key, "X");
    } else {
      remove(key);
    }
  }

  // A list written away on pagehide for the next page load. An empty list
  // writes nothing: a stored one is consumed on the next load (takeList),
  // so there is never a stale entry to overwrite.
  function saveList(key, list) {
    if (!list.length) return;
    try {
      window.sessionStorage?.setItem(key, JSON.stringify(list));
    } catch {
      // storage full or unavailable - the list simply does not survive
    }
  }

  // The list a previous page load stored, CONSUMED: the entry is removed
  // as it is read, so a later reload without a fresh write starts empty
  // instead of replaying it. [] when nothing was stored, when the stored
  // text is not a JSON array, or when storage is unavailable.
  function takeList(key) {
    let stored;
    try {
      stored = window.sessionStorage?.getItem(key);
      window.sessionStorage?.removeItem(key);
    } catch {
      return [];
    }
    if (!stored) return [];
    try {
      const parsed = JSON.parse(stored);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  return { read, write, remove, readFlag, writeFlag, saveList, takeList };
});
