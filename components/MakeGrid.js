import { Component } from "@noflo/noflo";

/**
 * Creates a grid of points by crossing the x and y coordinate arrays: every
 * x is combined with every y (y-major order). The contract is consistently
 * array-in/array-out; for a single point use `canvas/MakePoint`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates a grid of points from x and y coordinate arrays",
    icon: "crosshairs",
    inPorts: {
      x: {
        datatype: "array",
        description: "X coordinate array",
        required: true,
      },
      y: {
        datatype: "array",
        description: "Y coordinate array",
        required: true,
      },
    },
    outPorts: {
      points: {
        datatype: "array",
        description: "Array of point objects, x times y",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("x", "y")) {
      return;
    }
    const [xs, ys] = input.getData("x", "y");
    if (!Array.isArray(xs) || !Array.isArray(ys)) {
      output.error(new Error("MakeGrid requires x and y coordinate arrays"));
      output.done();
      return;
    }
    /** @type {Record<string, unknown>[]} */
    const points = [];
    for (const y of ys) {
      for (const x of xs) {
        points.push({ type: "point", x, y });
      }
    }
    output.sendDone({ points });
  });

  return c;
}
