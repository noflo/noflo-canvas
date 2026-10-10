import { Component } from "@noflo/noflo";

/**
 * Makes an array of evenly-spaced numbers between from and to.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Make an array of evenly-spaced numbers",
    icon: "folder-o",
    inPorts: {
      from: {
        datatype: "number",
        required: true,
      },
      to: {
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
      range: {
        datatype: "array",
        description: "Array of evenly-spaced numbers",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("from", "to", "count")) {
      return;
    }
    const [from, to, count] = input.getData("from", "to", "count");
    if (count === 1) {
      output.sendDone({ range: [from] });
      return;
    }
    /** @type {number[]} */
    const range = [];
    const spread = to - from;
    const increment = spread / (count - 1);
    for (let i = 0; i < count; i += 1) {
      range.push(from + increment * i);
    }
    output.sendDone({ range });
  });

  return c;
}
