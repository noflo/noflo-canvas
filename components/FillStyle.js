import { Component } from "@noflo/noflo";

/**
 * Creates a fill-style drawing command: sets the global fill style the
 * `canvas/Draw` context uses for subsequent fills.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Sets the global fill style",
    icon: "pencil-square-o",
    inPorts: {
      style: {
        datatype: "string",
        description: "CSS color or style string",
        required: true,
      },
    },
    outPorts: {
      fillstyle: {
        datatype: "object",
        description: "Fill style command object",
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
      fillstyle: { type: "fillStyle", value: input.getData("style") },
    });
  });

  return c;
}
