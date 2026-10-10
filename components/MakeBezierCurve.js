import { Component } from "@noflo/noflo";

/**
 * Creates a Bezier curve object for the canvas drawing vocabulary.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates a Bezier curve",
    icon: "pencil-square",
    inPorts: {
      control1: {
        datatype: "object",
        description: "Control point 1",
        required: true,
      },
      control2: {
        datatype: "object",
        description: "Control point 2",
        required: true,
      },
      end: {
        datatype: "object",
        description: "End point",
        required: true,
      },
    },
    outPorts: {
      beziercurve: {
        datatype: "object",
        description: "Bezier curve object with type and control points",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("control1", "control2", "end")) {
      return;
    }
    const [control1, control2, end] = input.getData(
      "control1",
      "control2",
      "end",
    );
    output.sendDone({
      beziercurve: { type: "beziercurve", control1, control2, end },
    });
  });

  return c;
}
