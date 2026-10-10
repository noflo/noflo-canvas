import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";

/**
 * Flattens drawing commands or primitives into a single array. Fires when
 * every attached index of the addressable `items` port has data; arrays
 * among the items are concatenated into the group.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Group drawing commands or primitives into a flattened array",
    icon: "folder-o",
    inPorts: {
      items: {
        datatype: "object",
        description: "Drawing commands or primitives to group",
        addressable: true,
        required: true,
      },
    },
    outPorts: {
      group: {
        datatype: "array",
        description: "Flattened array of items",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    const attached = /** @type {number[]} */ (input.attached("items"));
    const indexes = dataIndexes(input, "items");
    // 1.x waited for every attached index to carry data; keep that gate
    if (indexes.length !== attached.length) {
      return;
    }
    /** @type {unknown[]} */
    const group = [];
    for (const idx of indexes) {
      const data = input.getData(["items", idx]);
      if (Array.isArray(data)) {
        group.push(...data);
      } else {
        group.push(data);
      }
    }
    output.sendDone({ group });
  });

  return c;
}
