import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";

/**
 * Creates a fill drawing command over the shapes received in this
 * activation. Shapes arriving as arrays pass through — `canvas/Draw`
 * recurses into them.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Fills the received paths, rectangles, circles, and arcs",
    icon: "square",
    inPorts: {
      items: {
        datatype: "object",
        description: "Shapes (paths, circles, and rectangles) to fill",
        addressable: true,
        required: true,
      },
      fillstyle: {
        datatype: "string",
        description: "CSS color string",
        required: false,
        control: true,
      },
    },
    outPorts: {
      fill: {
        datatype: "object",
        description: "Fill command object with the collected items",
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
    /** @type {Record<string, unknown>} */
    const fill = { type: "fill", items };
    if (input.hasData("fillstyle")) {
      fill.fillstyle = input.getData("fillstyle");
    }
    output.sendDone({ fill });
  });

  return c;
}
