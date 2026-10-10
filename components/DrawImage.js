import { Component } from "@noflo/noflo";

/**
 * Creates a draw-image command for `canvas/Draw`. The `image` port accepts
 * a canvas object (or, in browsers, an image or video element). With only
 * `destpoint` the image is drawn at full size; `destrect` scales it, and
 * `sourcerect` picks a source region.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Draws the specified image",
    icon: "pencil-square",
    inPorts: {
      image: {
        datatype: "object",
        description: "Canvas, image, or video to draw",
        required: true,
      },
      destpoint: {
        datatype: "object",
        description: "Destination point (full size)",
        required: false,
        default: { x: 0, y: 0 },
      },
      destrect: {
        datatype: "object",
        description: "Destination rect, to scale",
        required: false,
      },
      sourcerect: {
        datatype: "object",
        description: "Source rect, to crop",
        required: false,
      },
    },
    outPorts: {
      drawimage: {
        datatype: "object",
        description: "Draw image command object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("image")) {
      return;
    }
    const image = input.getData("image");
    // The port default is network-delivered; a bare wiring falls back here
    const destpoint = input.hasData("destpoint")
      ? input.getData("destpoint")
      : { x: 0, y: 0 };
    /** @type {Record<string, unknown>} */
    const drawimage = { type: "drawimage", image, destpoint };
    if (input.hasData("destrect")) {
      drawimage.destrect = input.getData("destrect");
    }
    if (input.hasData("sourcerect")) {
      drawimage.sourcerect = input.getData("sourcerect");
    }
    output.sendDone({ drawimage });
  });

  return c;
}
