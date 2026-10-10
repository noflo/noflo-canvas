import { Component } from "@noflo/noflo";

/**
 * Makes an array of random numbers between min and max.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Make an array of random numbers",
    icon: "random",
    inPorts: {
      min: {
        datatype: "number",
        required: true,
      },
      max: {
        datatype: "number",
        required: true,
      },
      count: {
        datatype: "int",
        description: "How many numbers to generate",
        required: true,
      },
    },
    outPorts: {
      numbers: {
        datatype: "array",
        description: "Array of random numbers",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("min", "max", "count")) {
      return;
    }
    const [min, max, count] = input.getData("min", "max", "count");
    const spread = max - min;
    /** @type {number[]} */
    const numbers = [];
    for (let i = 0; i < count; i += 1) {
      numbers.push(min + Math.random() * spread);
    }
    output.sendDone({ numbers });
  });

  return c;
}
