import { canvasToPng } from "@noflo/canvas/engine";
import { Component } from "@noflo/noflo";

/**
 * Encodes a canvas as PNG bytes. Unlike the 1.x components, this is a
 * single isomorphic component: browsers encode through the Blob API and
 * Node.js through pureimage, and the output is image bytes rather than a
 * data URL or a written file.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Encodes a canvas to PNG bytes",
    icon: "file-image-o",
    inPorts: {
      canvas: {
        datatype: "object",
        description: "Canvas to encode",
        required: true,
      },
    },
    outPorts: {
      png: {
        datatype: "all",
        description: "PNG image bytes",
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
      const bytes = await canvasToPng(input.getData("canvas"));
      output.sendDone({ png: bytes });
    } catch (error) {
      output.error(error instanceof Error ? error : new Error(String(error)));
      output.done();
    }
  });

  return c;
}
