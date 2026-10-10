import { Component } from "@noflo/noflo";

/**
 * Creates a rectangle, maintaining the original aspect ratio. Negative
 * `width` or `height` values mean "don't care" and are derived from the
 * other dimension and the original proportions.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates a rectangle, maintaining original aspect ratio",
    icon: "square-o",
    inPorts: {
      width: {
        datatype: "number",
        description: "Target width; negative for don't-care",
        required: true,
      },
      height: {
        datatype: "number",
        description: "Target height; negative for don't-care",
        required: true,
      },
      origwidth: {
        datatype: "number",
        description: "Original width",
        required: true,
      },
      origheight: {
        datatype: "number",
        description: "Original height",
        // Effectively required: the 1.x compute gate demanded it despite
        // declaring the port optional
        required: true,
      },
    },
    outPorts: {
      rectangle: {
        datatype: "object",
        description: "Rectangle object anchored at the origin",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("width", "height", "origwidth", "origheight")) {
      return;
    }
    const [width, height, origwidth, origheight] = input.getData(
      "width",
      "height",
      "origwidth",
      "origheight",
    );
    const aspectRatio = origheight / origwidth;
    let targetWidth = width;
    let targetHeight = height;
    if (width < 0 && height < 0) {
      // Pass through the original dimensions
      targetWidth = origwidth;
      targetHeight = origheight;
    } else if (width < 0) {
      targetWidth = targetHeight / aspectRatio;
    } else if (height < 0) {
      targetHeight = targetWidth * aspectRatio;
    }
    output.sendDone({
      rectangle: {
        type: "rectangle",
        point: { type: "point", x: 0, y: 0 },
        width: targetWidth,
        height: targetHeight,
      },
    });
  });

  return c;
}
