import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";

/**
 * Creates a stroke drawing command over the shapes received in this
 * activation. Shapes arriving as arrays pass through — `canvas/Draw`
 * recurses into them.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Strokes lines for paths, rectangles, circles, and arcs",
    icon: "square-o",
    inPorts: {
      items: {
        datatype: "object",
        description: "Shapes (paths, circles, and rectangles) to stroke",
        addressable: true,
        required: true,
      },
      strokestyle: {
        datatype: "string",
        description: "CSS color string or canvas style",
        required: false,
        control: true,
      },
      linewidth: {
        datatype: "number",
        description: "Stroke width in pixels",
        required: false,
        control: true,
      },
      closepath: {
        datatype: "boolean",
        description: "Draw line back to start point",
        required: false,
        control: true,
        default: false,
      },
    },
    outPorts: {
      stroke: {
        datatype: "object",
        description: "Stroke command object with the collected items",
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
    const stroke = { type: "stroke", items };
    if (input.hasData("strokestyle")) {
      stroke.strokestyle = input.getData("strokestyle");
    }
    if (input.hasData("linewidth")) {
      stroke.linewidth = input.getData("linewidth");
    }
    // Guard the control read: the network delivers the default, but a bare
    // component wiring may not have it yet
    stroke.closepath = input.hasData("closepath")
      ? input.getData("closepath")
      : false;
    output.sendDone({ stroke });
  });

  return c;
}
