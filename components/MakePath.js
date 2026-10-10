import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";

/**
 * Makes a path from the points, arcs, and curves received in this
 * activation. Arrays among the items pass through as-is — `canvas/Draw`
 * recurses into them when building the path.
 *
 * The 1.x component unwrapped single-array activations and fanned out
 * multiple arrays into path combinations; the 2.x component keeps the
 * collected items verbatim, since the draw-side recursion covers the same
 * rendering.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Makes a path given a number of points, curves, etc",
    icon: "star-o",
    inPorts: {
      items: {
        datatype: "object",
        description: "Points, arcs, and curves to combine to make path",
        addressable: true,
        required: true,
      },
    },
    outPorts: {
      path: {
        datatype: "object",
        description: "Path command object with the collected items",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    const indexes = dataIndexes(input, "items");
    if (indexes.length === 0) {
      return;
    }
    const items = indexes.map((idx) => input.getData(["items", idx]));
    output.sendDone({ path: { type: "path", items } });
  });

  return c;
}
