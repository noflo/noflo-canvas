import { canvasToJpeg } from "@noflo/canvas/engine";
import { Component } from "@noflo/noflo";

/**
 * Encodes a canvas as JPEG bytes.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Encodes a canvas to JPEG bytes",
    icon: "file-image-o",
    inPorts: {
      canvas: {
        datatype: "object",
        description: "Canvas to encode",
        required: true,
      },
    },
    outPorts: {
      jpeg: {
        datatype: "all",
        description: "JPEG image bytes",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process(async (input, output) => {
    if (!input.hasData("canvas")) {
      return;
    }
    try {
      const bytes = await canvasToJpeg(input.getData("canvas"));
      output.sendDone({ jpeg: bytes });
    } catch (error) {
      output.error(error instanceof Error ? error : new Error(String(error)));
      output.done();
    }
  });

  return c;
}
