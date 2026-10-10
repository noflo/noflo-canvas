import { createCanvas } from "@noflo/canvas/engine";
import { Component } from "@noflo/noflo";

/**
 * Creates a canvas object with the given dimensions. The canvas flows
 * through graph ports as data and works in both Node.js (pureimage) and
 * browsers (native canvas).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Makes a canvas with the given dimensions",
    icon: "pencil-square",
    inPorts: {
      width: {
        datatype: "int",
        description: "Canvas width in pixels",
        required: true,
      },
      height: {
        datatype: "int",
        description: "Canvas height in pixels",
        required: true,
      },
    },
    outPorts: {
      canvas: {
        datatype: "object",
        description: "The created canvas",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("width", "height")) {
      return;
    }
    const [width, height] = input.getData("width", "height");
    try {
      const canvas = createCanvas(width, height);
      output.sendDone({ canvas });
    } catch (error) {
      output.error(error instanceof Error ? error : new Error(String(error)));
      output.done();
    }
  });

  return c;
}
