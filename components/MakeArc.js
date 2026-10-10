import { Component } from "@noflo/noflo";

/**
 * Creates an arc object for the canvas drawing vocabulary. Angles are in
 * radians, matching the Web Canvas 2D `arc()` convention.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates an arc",
    icon: "power-off",
    inPorts: {
      center: {
        datatype: "object",
        description: "Point for center",
        required: true,
      },
      radius: {
        datatype: "number",
        required: true,
      },
      start: {
        datatype: "number",
        description: "Start angle in radians",
        required: true,
      },
      end: {
        datatype: "number",
        description: "End angle in radians",
        required: true,
      },
      reverse: {
        datatype: "boolean",
        description: "Draw the arc counterclockwise",
        required: false,
        control: true,
        default: false,
      },
    },
    outPorts: {
      arc: {
        datatype: "object",
        description: "Arc object with type, center, radius, and angles",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("center", "radius", "start", "end")) {
      return;
    }
    const [center, radius, start, end] = input.getData(
      "center",
      "radius",
      "start",
      "end",
    );
    // Guard the control read: the network delivers the default, but a bare
    // component wiring may not have it yet
    const reverse = input.hasData("reverse") ? input.getData("reverse") : false;
    output.sendDone({
      arc: { type: "arc", center, radius, start, end, reverse },
    });
  });

  return c;
}
