import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";

/**
 * Creates a transform drawing command: applies translate, rotate, and/or
 * scale to the drawing commands received in this activation, then undoes
 * the transformation (drawing commands nest inside `items`).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Translate, rotate, and/or scale passed drawing commands",
    icon: "arrows",
    inPorts: {
      items: {
        datatype: "object",
        description: "Fill and stroke commands to transform",
        addressable: true,
        required: true,
      },
      translate: {
        datatype: "object",
        description: "Translate by this point",
        required: false,
        control: true,
      },
      scale: {
        datatype: "object",
        description: "Scale by this point (stretch or mirror)",
        required: false,
        control: true,
      },
      scaleboth: {
        datatype: "number",
        description: "Scale both x and y by this factor",
        required: false,
        control: true,
      },
      rotate: {
        datatype: "number",
        description: "Rotate by this angle in radians",
        required: false,
        control: true,
      },
    },
    outPorts: {
      transform: {
        datatype: "object",
        description: "Transform command object",
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
    const transform = { type: "transform", items };
    if (input.hasData("translate")) {
      transform.translate = input.getData("translate");
    }
    if (input.hasData("scale")) {
      transform.scale = input.getData("scale");
    }
    if (input.hasData("scaleboth")) {
      transform.scaleboth = input.getData("scaleboth");
    }
    if (input.hasData("rotate")) {
      transform.rotate = input.getData("rotate");
    }
    output.sendDone({ transform });
  });

  return c;
}
