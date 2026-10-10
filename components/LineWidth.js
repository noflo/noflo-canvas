import { Component } from "@noflo/noflo";

/**
 * Creates a line-width drawing command: sets the line width the
 * `canvas/Draw` context uses for subsequent strokes.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Sets the line width",
    icon: "pencil-square",
    inPorts: {
      width: {
        datatype: "number",
        description: "Line width in pixels",
        required: true,
      },
    },
    outPorts: {
      linewidth: {
        datatype: "object",
        description: "Line width command object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("width")) {
      return;
    }
    output.sendDone({
      linewidth: { type: "lineWidth", value: input.getData("width") },
    });
  });

  return c;
}
