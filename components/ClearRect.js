import { Component } from "@noflo/noflo";

/**
 * Creates a clear-rectangle drawing command for `canvas/Draw`: erases the
 * given rectangle region.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Clear rectangle",
    icon: "eraser",
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
      clearrect: {
        datatype: "object",
        description: "Clear rectangle command object",
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
    output.sendDone({ clearrect: { type: "clearrect", point, width, height } });
  });

  return c;
}
