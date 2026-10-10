import { Component } from "@noflo/noflo";

/**
 * Creates a stroke-rectangle drawing command for `canvas/Draw`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Strokes a rectangle",
    icon: "pencil-square-o",
    inPorts: {
      point: {
        datatype: "object",
        description: "Top left point",
        required: true,
      },
      width: {
        datatype: "number",
        required: true,
      },
      height: {
        datatype: "number",
        required: true,
      },
    },
    outPorts: {
      strokerect: {
        datatype: "object",
        description: "Stroke rectangle command object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("point", "width", "height")) {
      return;
    }
    const [point, width, height] = input.getData("point", "width", "height");
    output.sendDone({
      strokerect: { type: "strokerect", point, width, height },
    });
  });

  return c;
}
