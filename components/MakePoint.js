import { Component } from "@noflo/noflo";

/**
 * Creates a point object for the canvas drawing vocabulary. One point per
 * activation; arrays compose upstream through streams.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates a point",
    icon: "crosshairs",
    inPorts: {
      x: {
        datatype: "number",
        description: "X coordinate",
        required: true,
      },
      y: {
        datatype: "number",
        description: "Y coordinate",
        required: true,
      },
    },
    outPorts: {
      point: {
        datatype: "object",
        description: "Point object with type and coordinates",
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
    const [x, y] = input.getData("x", "y");
    output.sendDone({ point: { type: "point", x, y } });
  });

  return c;
}
