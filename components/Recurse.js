import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";

/**
 * Makes a translate command recursive: the collected `recursables` (only
 * `transform` commands are recursable) are re-applied `count` times.
 *
 * State is kept per scope, like the 1.x component: `recursables` slots are
 * positional (index-addressable), and `count` triggers emission of the
 * current recurse object.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  /**
   * Per-scope recurse state.
   * @typedef {object} RecurseState
   * @property {unknown[]} recursables
   * @property {number | null} count
   */
  /** @type {Record<string, RecurseState>} */
  const scopes = {};

  const c = new Component({
    description: "Makes a translation recursive",
    icon: "retweet",
    inPorts: {
      recursables: {
        datatype: "object",
        description: "Only transform is recursable",
        addressable: true,
        required: false,
      },
      count: {
        datatype: "number",
        description: "How many times to recurse",
        required: false,
      },
    },
    outPorts: {
      recurse: {
        datatype: "object",
        description: "Recurse command object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.tearDown = async () => {
    for (const key of Object.keys(scopes)) {
      delete scopes[key];
    }
  };

  /**
   * Ensures state for the given scope.
   * @param {string} scope
   * @returns {RecurseState}
   */
  const ensureScope = (scope) => {
    if (!scopes[scope]) {
      scopes[scope] = { recursables: [], count: null };
    }
    return scopes[scope];
  };

  c.process((input, output) => {
    const state = ensureScope(input.scope ?? "");
    if (input.hasData("count")) {
      state.count = input.getData("count");
      if (state.recursables.length === 0) {
        output.done();
        return;
      }
      output.sendDone({
        recurse: {
          type: "recurse",
          recursables: state.recursables,
          count: state.count,
        },
      });
      return;
    }
    const indexes = dataIndexes(input, "recursables");
    if (indexes.length === 0) {
      return;
    }
    for (const idx of indexes) {
      state.recursables[idx] = input.getData(["recursables", idx]);
    }
    output.sendDone({
      recurse: {
        type: "recurse",
        recursables: state.recursables,
        count: state.count,
      },
    });
  });

  return c;
}
