import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";

import { getComponent as getCreateCanvas } from "../components/CreateCanvas.js";
import { getComponent as getDraw } from "../components/Draw.js";
import { getComponent as getSavePNG } from "../components/SavePNG.js";
import { createCanvas, decodeImage } from "../lib/engines/node.js";

/**
 * Waits for the next data IP on a socket.
 * @param {import("@noflo/noflo").internalSocket.InternalSocket} socket
 * @returns {Promise<import("@noflo/noflo").IP>}
 */
const nextData = (socket) =>
  new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      cleanup();
      reject(new Error("Timed out waiting for IP"));
    }, 2000);
    /** @param {CustomEvent} event */
    const listener = (event) => {
      if (event.detail.type === "data") {
        cleanup();
        resolve(event.detail);
      }
    };
    const cleanup = () => {
      clearTimeout(timer);
      socket.removeEventListener("ip", listener);
    };
    socket.addEventListener("ip", listener);
  });

describe("Draw end-to-end", () => {
  it("draws buffered commands on tick and emits the canvas", async () => {
    const draw = getDraw();
    const canvasControl = noflo.internalSocket.createSocket();
    const command = noflo.internalSocket.createSocket();
    const tick = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    draw.inPorts.canvas.attach(canvasControl);
    draw.inPorts.commands.attach(command, 0);
    draw.inPorts.tick.attach(tick);
    draw.outPorts.canvas.attach(outSocket);
    try {
      const canvas = createCanvas(10, 10);
      canvas.getContext("2d").fillStyle = "rgb(255, 0, 0)";
      // Canvas and command are controls/command buffer: send them, then
      // the tick completes the firing pattern
      canvasControl.post(new noflo.IP("data", canvas));
      command.post(
        new noflo.IP(
          "data",
          {
            type: "fillrect",
            point: { type: "point", x: 2, y: 2 },
            width: 4,
            height: 4,
          },
          /** @type {any} */ ({ index: 0 }),
        ),
      );
      const received = nextData(outSocket);
      tick.post(new noflo.IP("data", true));
      const ip = await received;
      assert.equal(ip.data, canvas);
      // Verify the rectangle was drawn: center pixel is red
      const data = canvas.getContext("2d").getImageData(4, 4, 1, 1);
      assert.equal(data.data[0], 255);
      assert.equal(data.data[1], 0);
      assert.equal(data.data[2], 0);
    } finally {
      await draw.shutdown();
    }
  });

  it("buffers commands across activations until tick", async () => {
    const draw = getDraw();
    const canvasControl = noflo.internalSocket.createSocket();
    const first = noflo.internalSocket.createSocket();
    const second = noflo.internalSocket.createSocket();
    const tick = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    draw.inPorts.canvas.attach(canvasControl);
    draw.inPorts.commands.attach(first, 0);
    draw.inPorts.commands.attach(second, 1);
    draw.inPorts.tick.attach(tick);
    draw.outPorts.canvas.attach(outSocket);
    try {
      const canvas = createCanvas(10, 10);
      canvasControl.post(new noflo.IP("data", canvas));
      first.post(
        new noflo.IP(
          "data",
          {
            type: "fillrect",
            point: { type: "point", x: 0, y: 0 },
            width: 2,
            height: 2,
          },
          /** @type {any} */ ({ index: 0 }),
        ),
      );
      // No send yet: drawevery is false and no tick arrived
      const silent = nextData(outSocket).then(
        () => {
          throw new Error("Drew before tick");
        },
        () => "timed-out",
      );
      assert.equal(
        await Promise.race([
          silent,
          new Promise((r) => setTimeout(() => r("silent"), 100)),
        ]),
        "silent",
      );
      second.post(
        new noflo.IP(
          "data",
          {
            type: "fillrect",
            point: { type: "point", x: 5, y: 5 },
            width: 2,
            height: 2,
          },
          /** @type {any} */ ({ index: 1 }),
        ),
      );
      const received = nextData(outSocket);
      tick.post(new noflo.IP("data", true));
      await received;
      const data = canvas.getContext("2d").getImageData(6, 6, 1, 1);
      // Default fill style is black
      assert.equal(data.data[3], 255);
    } finally {
      await draw.shutdown();
    }
  });

  it("wires the full graph: CreateCanvas, commands, Draw, SavePNG", async () => {
    const create = getCreateCanvas();
    const draw = getDraw();
    const save = getSavePNG();

    const canvasOut = noflo.internalSocket.createSocket();
    create.outPorts.canvas.attach(canvasOut);
    draw.inPorts.canvas.attach(canvasOut);
    const drawOut = noflo.internalSocket.createSocket();
    draw.outPorts.canvas.attach(drawOut);
    save.inPorts.canvas.attach(drawOut);

    const commandSocket = noflo.internalSocket.createSocket();
    draw.inPorts.commands.attach(commandSocket, 0);
    const drawEvery = noflo.internalSocket.createSocket();
    draw.inPorts.drawevery.attach(drawEvery);

    try {
      const pngSocket = noflo.internalSocket.createSocket();
      save.outPorts.png.attach(pngSocket);
      const pngReceived = nextData(pngSocket);

      // Fire the graph: drawevery control and the canvas creation come
      // first, then the command batch draws immediately
      drawEvery.post(new noflo.IP("data", true));
      const width = noflo.internalSocket.createSocket();
      const height = noflo.internalSocket.createSocket();
      create.inPorts.width.attach(width);
      create.inPorts.height.attach(height);
      width.post(new noflo.IP("data", 10));
      height.post(new noflo.IP("data", 10));
      commandSocket.post(
        new noflo.IP(
          "data",
          [
            { type: "fillStyle", value: "rgb(0, 0, 255)" },
            {
              type: "fillrect",
              point: { type: "point", x: 1, y: 1 },
              width: 5,
              height: 5,
            },
          ],
          /** @type {any} */ ({ index: 0 }),
        ),
      );
      const ip = await pngReceived;
      const bytes = /** @type {Uint8Array} */ (ip.data);
      assert.equal(bytes[0], 0x89);
      const decoded = await decodeImage(bytes);
      const data = decoded.getContext("2d").getImageData(2, 2, 1, 1);
      assert.equal(data.data[2], 255);
      assert.equal(data.data[0], 0);
    } finally {
      await create.shutdown();
      await draw.shutdown();
      await save.shutdown();
    }
  });
});
