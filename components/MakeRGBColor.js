import { Component } from "@noflo/noflo";

/**
 * Creates a CSS `rgb()`/`rgba()` color string from RGB channels. One color
 * per activation.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Creates an RGB or RGBA color",
    icon: "tint",
    inPorts: {
      red: {
        datatype: "int",
        description: "From 0 to 255",
        required: true,
      },
      green: {
        datatype: "int",
        description: "From 0 to 255",
        required: true,
      },
      blue: {
        datatype: "int",
        description: "From 0 to 255",
        required: true,
      },
      alpha: {
        datatype: "number",
        description: "Optional, from 0 to 1.0",
        required: false,
      },
    },
    outPorts: {
      color: {
        datatype: "string",
        description: "CSS rgb() color string",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("red", "green", "blue")) {
      return;
    }
    const [red, green, blue] = input.getData("red", "green", "blue");
    if (input.hasData("alpha")) {
      const alpha = input.getData("alpha");
      output.sendDone({
        color: `rgba(${Math.round(red)}, ${Math.round(green)}, ${Math.round(blue)}, ${alpha})`,
      });
      return;
    }
    output.sendDone({
      color: `rgb(${Math.round(red)}, ${Math.round(green)}, ${Math.round(blue)})`,
    });
  });

  return c;
}
