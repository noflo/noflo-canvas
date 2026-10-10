import { Component } from "@noflo/noflo";

/**
 * Creates a rectangle object for the canvas drawing vocabulary.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates a rectangle",
    icon: "square-o",
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
      rectangle: {
        datatype: "object",
        description: "Rectangle object with type, point, and dimensions",
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
    output.sendDone({ rectangle: { type: "rectangle", point, width, height } });
  });

  return c;
}
