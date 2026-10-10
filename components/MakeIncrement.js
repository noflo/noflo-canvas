import { Component } from "@noflo/noflo";

/**
 * Makes an array of numbers counting by an increment, ascending or
 * descending depending on the from/to order.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Make an array of numbers by increment",
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
      increment: {
        datatype: "int",
        description: "Step size",
        required: false,
        control: true,
        default: 1,
      },
    },
    outPorts: {
      range: {
        datatype: "array",
        description: "Array of numbers from `from` to `to`",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("from", "to")) {
      return;
    }
    const [from, to] = input.getData("from", "to");
    const increment = input.hasData("increment")
      ? input.getData("increment")
      : 1;
    /** @type {number[]} */
    const range = [];
    if (from <= to) {
      for (let value = from; value <= to; value += increment) {
        range.push(value);
      }
    } else {
      for (let value = from; value >= to; value -= increment) {
        range.push(value);
      }
    }
    output.sendDone({ range });
  });

  return c;
}
