import { Component } from "@noflo/noflo";

/**
 * Creates a CSS `hsl()`/`hsla()` color string from HSL channels. One color
 * per activation.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates an HSL or HSLA color",
    icon: "tint",
    inPorts: {
      hue: {
        datatype: "number",
        description: "From 0 to 360",
        required: true,
      },
      saturation: {
        datatype: "number",
        description: "From 0 to 100",
        required: true,
      },
      lightness: {
        datatype: "number",
        description: "From 0 to 100",
        required: true,
      },
      alpha: {
        datatype: "number",
        description: "From 0 to 1.0",
        required: false,
      },
    },
    outPorts: {
      color: {
        datatype: "string",
        description: "CSS hsl() color string",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("hue", "saturation", "lightness")) {
      return;
    }
    const [hue, saturation, lightness] = input.getData(
      "hue",
      "saturation",
      "lightness",
    );
    if (input.hasData("alpha")) {
      const alpha = input.getData("alpha");
      output.sendDone({
        color: `hsla(${hue}, ${saturation}%, ${lightness}%, ${alpha})`,
      });
      return;
    }
    output.sendDone({
      color: `hsl(${hue}, ${saturation}%, ${lightness}%)`,
    });
  });

  return c;
}
