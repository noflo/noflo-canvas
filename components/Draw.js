import { Component } from "@noflo/noflo";
import { dataIndexes } from "../lib/addressable.js";
import { DrawCommands } from "../lib/DrawCommands.js";

/**
 * Draws received drawing commands onto a canvas. Commands accumulate in a
 * per-scope buffer; a `tick` triggers drawing of everything buffered so
 * far. With `drawevery` enabled, every received command batch is drawn
 * immediately without waiting for a tick.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  /**
   * Per-scope drawing state.
   * @typedef {object} DrawScope
   * @property {unknown[]} commands
   * @property {import("../lib/engines/types.js").EngineContext} context
   * @property {import("../lib/engines/types.js").CanvasLike} canvas
   */
  /** @type {Record<string, DrawScope>} */
  const scopes = {};

  const c = new Component({
    description: "Draws received drawing commands",
    icon: "pencil",
    inPorts: {
      canvas: {
        datatype: "object",
        description: "Canvas to draw onto",
        required: true,
        control: true,
      },
      commands: {
        datatype: "object",
        description: "Drawing commands to buffer",
        addressable: true,
        required: false,
      },
      tick: {
        datatype: "bang",
        description: "Draw all buffered commands",
        required: false,
      },
      drawevery: {
        datatype: "boolean",
        description: "Draw on every command batch instead of waiting for tick",
        required: false,
        control: true,
        default: false,
      },
      clearevery: {
        datatype: "boolean",
        description: "Clear the canvas before each drawing pass",
        required: false,
        control: true,
        default: false,
      },
    },
    outPorts: {
      canvas: {
        datatype: "object",
        description: "The drawn-upon canvas",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.forwardBrackets = { tick: ["canvas", "error"] };

  c.tearDown = async () => {
    for (const key of Object.keys(scopes)) {
      delete scopes[key];
    }
  };

  /**
   * Ensures per-scope state, switching the context when the canvas changes.
   * @param {string} scope
   * @param {import("../lib/engines/types.js").CanvasLike} canvas
   * @returns {DrawScope}
   */
  const ensureScope = (scope, canvas) => {
    const existing = scopes[scope];
    if (existing) {
      if (existing.canvas !== canvas) {
        existing.canvas = canvas;
        existing.context = canvas.getContext("2d");
      }
      return existing;
    }
    const created = {
      commands: [],
      context: canvas.getContext("2d"),
      canvas,
    };
    scopes[scope] = created;
    return created;
  };

  /**
   * Draws all buffered commands for the scope.
   * @param {DrawScope} scope
   * @param {boolean} clearEvery
   * @param {import("../lib/engines/types.js").CanvasLike} canvas
   * @param {{ error(err: Error | Error[]): void, done(): void, sendDone(map: Record<string, unknown>): void }} output
   * @returns {void}
   */
  const drawBuffered = (scope, clearEvery, canvas, output) => {
    const draw = new DrawCommands(scope.context, canvas);
    try {
      draw.parse(scope.commands, clearEvery);
    } catch (error) {
      output.error(error instanceof Error ? error : new Error(String(error)));
      output.done();
      return;
    }
    output.sendDone({ canvas });
  };

  c.process((input, output) => {
    // A canvas is always required to operate on
    if (!input.hasData("canvas")) {
      return;
    }
    // Guard the control reads: the network delivers defaults, but a bare
    // wiring may not have them yet
    if (input.attached("drawevery").length && !input.hasData("drawevery")) {
      return;
    }
    if (input.attached("clearevery").length && !input.hasData("clearevery")) {
      return;
    }

    const canvas = input.getData("canvas");
    const scope = ensureScope(input.scope ?? "", canvas);

    if (input.hasData("tick")) {
      input.getData("tick");
      const clearEvery = input.hasData("clearevery")
        ? input.getData("clearevery")
        : false;
      drawBuffered(scope, clearEvery, canvas, output);
      return;
    }

    // Check for drawing commands
    const indexes = dataIndexes(input, "commands");
    if (indexes.length === 0) {
      // The canvas was already read above, which activated this context:
      // every path after a get must complete
      output.done();
      return;
    }

    const drawEvery = input.hasData("drawevery")
      ? input.getData("drawevery")
      : false;
    const clearEvery = input.hasData("clearevery")
      ? input.getData("clearevery")
      : false;

    for (const idx of indexes) {
      // Read commands into the scope buffer, positionally
      scope.commands[idx] = input.getData(["commands", idx]);
    }

    if (!drawEvery) {
      // Wait for a tick
      output.done();
      return;
    }
    drawBuffered(scope, clearEvery, canvas, output);
  });

  return c;
}
