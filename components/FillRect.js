import { Component } from "@noflo/noflo";

/**
 * Creates a fill-rectangle drawing command for `canvas/Draw`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Fills a rectangle",
    icon: "pencil-square",
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
      fillrect: {
        datatype: "object",
        description: "Fill rectangle command object",
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
    output.sendDone({ fillrect: { type: "fillrect", point, width, height } });
  });

  return c;
}
