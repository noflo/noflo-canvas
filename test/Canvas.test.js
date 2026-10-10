import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";

import { getComponent as getCreateCanvas } from "../components/CreateCanvas.js";
import { getComponent as getMakePoint } from "../components/MakePoint.js";
import { getComponent as getSaveJPEG } from "../components/SaveJPEG.js";
import { getComponent as getSavePNG } from "../components/SavePNG.js";

/**
 * Waits for the next IP on a socket matching the predicate.
 * @param {import("@noflo/noflo").internalSocket.InternalSocket} socket
 * @param {(ip: import("@noflo/noflo").IP) => boolean} predicate
 * @returns {Promise<import("@noflo/noflo").IP>}
 */
const waitUntil = (socket, predicate) =>
  new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      cleanup();
      reject(new Error("Timed out waiting for IP"));
    }, 2000);
    /** @param {CustomEvent} event */
    const listener = (event) => {
      const ip = event.detail;
      if (predicate(ip)) {
        cleanup();
        resolve(ip);
      }
    };
    const cleanup = () => {
      clearTimeout(timer);
      socket.removeEventListener("ip", listener);
    };
    socket.addEventListener("ip", listener);
  });

/** @param {import("@noflo/noflo").Component} component @param {string} port */
const receive = (component, port) => {
  const socket = noflo.internalSocket.createSocket();
  component.outPorts[port].attach(socket);
  return waitUntil(socket, (ip) => ip.type === "data");
};

describe("CreateCanvas component", () => {
  it("creates a canvas with the given dimensions", async () => {
    const c = getCreateCanvas();
    const width = noflo.internalSocket.createSocket();
    const height = noflo.internalSocket.createSocket();
    c.inPorts.width.attach(width);
    c.inPorts.height.attach(height);
    try {
      const received = receive(c, "canvas");
      width.post(new noflo.IP("data", 20));
      height.post(new noflo.IP("data", 10));
      const ip = await received;
      const canvas = ip.data;
      assert.equal(canvas.width, 20);
      assert.equal(canvas.height, 10);
      const ctx = canvas.getContext("2d");
      assert.equal(typeof ctx.fillRect, "function");
      assert.equal(typeof ctx.beginPath, "function");
    } finally {
      await c.shutdown();
    }
  });
});

describe("MakePoint component", () => {
  it("creates a typed point object", async () => {
    const c = getMakePoint();
    const x = noflo.internalSocket.createSocket();
    const y = noflo.internalSocket.createSocket();
    c.inPorts.x.attach(x);
    c.inPorts.y.attach(y);
    try {
      const received = receive(c, "point");
      x.post(new noflo.IP("data", 5));
      y.post(new noflo.IP("data", 10));
      const ip = await received;
      assert.deepEqual(ip.data, { type: "point", x: 5, y: 10 });
    } finally {
      await c.shutdown();
    }
  });
  it("waits for both coordinates", async () => {
    const c = getMakePoint();
    const x = noflo.internalSocket.createSocket();
    const y = noflo.internalSocket.createSocket();
    c.inPorts.x.attach(x);
    c.inPorts.y.attach(y);
    try {
      const received = receive(c, "point");
      x.post(new noflo.IP("data", 5));
      const early = received.then(
        () => {
          throw new Error("Sent before both coordinates arrived");
        },
        () => "timed-out",
      );
      assert.equal(
        await Promise.race([
          early,
          new Promise((r) => setTimeout(() => r("silent"), 100)),
        ]),
        "silent",
      );
      y.post(new noflo.IP("data", 10));
      const ip = await received;
      assert.deepEqual(ip.data, { type: "point", x: 5, y: 10 });
    } finally {
      await c.shutdown();
    }
  });
});

describe("SavePNG component", () => {
  it("encodes a drawn canvas to PNG bytes", async () => {
    const create = getCreateCanvas();
    const save = getSavePNG();
    const width = noflo.internalSocket.createSocket();
    const height = noflo.internalSocket.createSocket();
    create.inPorts.width.attach(width);
    create.inPorts.height.attach(height);
    const canvasSocket = noflo.internalSocket.createSocket();
    create.outPorts.canvas.attach(canvasSocket);
    save.inPorts.canvas.attach(canvasSocket);
    try {
      const encoded = receive(save, "png");
      width.post(new noflo.IP("data", 8));
      height.post(new noflo.IP("data", 8));
      const ip = await encoded;
      const bytes = ip.data;
      assert.ok(bytes instanceof Uint8Array);
      // PNG magic number
      assert.equal(bytes[0], 0x89);
      assert.equal(bytes[1], 0x50);
    } finally {
      await create.shutdown();
      await save.shutdown();
    }
  });
});

describe("SaveJPEG component", () => {
  it("encodes a drawn canvas to JPEG bytes", async () => {
    const create = getCreateCanvas();
    const save = getSaveJPEG();
    const width = noflo.internalSocket.createSocket();
    const height = noflo.internalSocket.createSocket();
    create.inPorts.width.attach(width);
    create.inPorts.height.attach(height);
    const canvasSocket = noflo.internalSocket.createSocket();
    create.outPorts.canvas.attach(canvasSocket);
    save.inPorts.canvas.attach(canvasSocket);
    try {
      const encoded = receive(save, "jpeg");
      width.post(new noflo.IP("data", 8));
      height.post(new noflo.IP("data", 8));
      const ip = await encoded;
      const bytes = ip.data;
      assert.ok(bytes instanceof Uint8Array);
      // JPEG magic number
      assert.equal(bytes[0], 0xff);
      assert.equal(bytes[1], 0xd8);
    } finally {
      await create.shutdown();
      await save.shutdown();
    }
  });
});
