import { Component } from "@noflo/noflo";

/**
 * Converts an `[r, g, b]` array to a CSS hex color string. The contract is
 * consistently array-in: a single RGB triple in, one hex string out.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Convert an RGB array to a hex value",
    icon: "tint",
    inPorts: {
      in: {
        datatype: "array",
        description: "RGB triple, e.g. [255, 0, 0]",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "string",
        description: "CSS hex color string",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const rgb = input.getData("in");
    if (!Array.isArray(rgb) || rgb.length < 3) {
      output.error(
        new Error(`Expected an [r, g, b] array: ${JSON.stringify(rgb)}`),
      );
      output.done();
      return;
    }
    const hex = (/** @type {number} */ n) => n.toString(16).padStart(2, "0");
    output.sendDone({
      out: `#${hex(rgb[0])}${hex(rgb[1])}${hex(rgb[2])}`,
    });
  });

  return c;
}
