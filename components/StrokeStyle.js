import { Component } from "@noflo/noflo";

/**
 * Creates a stroke-style drawing command: sets the global stroke style the
 * `canvas/Draw` context uses for subsequent strokes.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Sets the global stroke style",
    icon: "pencil-square-o",
    inPorts: {
      style: {
        datatype: "string",
        description: "CSS color or style string",
        required: true,
      },
    },
    outPorts: {
      strokestyle: {
        datatype: "object",
        description: "Stroke style command object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("style")) {
      return;
    }
    output.sendDone({
      strokestyle: { type: "strokeStyle", value: input.getData("style") },
    });
  });

  return c;
}
