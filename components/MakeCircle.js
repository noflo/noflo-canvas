import { Component } from "@noflo/noflo";

/**
 * Creates a circle object for the canvas drawing vocabulary.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates a circle",
    icon: "circle-o",
    inPorts: {
      center: {
        datatype: "object",
        description: "Center point",
        required: true,
      },
      radius: {
        datatype: "number",
        required: true,
      },
    },
    outPorts: {
      circle: {
        datatype: "object",
        description: "Circle object with type, center, and radius",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("center", "radius")) {
      return;
    }
    const [center, radius] = input.getData("center", "radius");
    output.sendDone({ circle: { type: "circle", center, radius } });
  });

  return c;
}
