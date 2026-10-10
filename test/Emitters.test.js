import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";

import { getComponent as getClearRect } from "../components/ClearRect.js";
import { getComponent as getDrawImage } from "../components/DrawImage.js";
import { getComponent as getFillRect } from "../components/FillRect.js";
import { getComponent as getMakePath } from "../components/MakePath.js";
import { getComponent as getRecurse } from "../components/Recurse.js";
import { getComponent as getStroke } from "../components/Stroke.js";
import { getComponent as getStrokeRect } from "../components/StrokeRect.js";
import { getComponent as getStrokeStyle } from "../components/StrokeStyle.js";
import { getComponent as getTransform } from "../components/Transform.js";
import { createCanvas } from "../lib/engines/node.js";

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

/**
 * Wires every input socket first (unattached optional ports make hasData
 * vacuously true), then posts in order, returning the first data value.
 * @param {import("@noflo/noflo").Component} c
 * @param {string} outPort
 * @param {Record<string, any>} inputs
 * @param {Record<string, number>} [indexed]
 * @returns {Promise<any>}
 */
const run = async (c, outPort, inputs, indexed = {}) => {
  const outSocket = noflo.internalSocket.createSocket();
  c.outPorts[outPort].attach(outSocket);
  const received = nextData(outSocket);
  /** @type {Record<string, import("@noflo/noflo").internalSocket.InternalSocket>} */
  const sockets = {};
  for (const port of new Set([...Object.keys(inputs), ...Object.keys(indexed)])) {
    const socket = noflo.internalSocket.createSocket();
    if (port in indexed) {
      c.inPorts[port].attach(socket, indexed[port]);
    } else {
      c.inPorts[port].attach(socket);
    }
    sockets[port] = socket;
  }
  for (const [port, value] of Object.entries(inputs)) {
    if (port in indexed) {
      sockets[port].post(
        new noflo.IP("data", value, /** @type {any} */ ({ index: indexed[port] })),
      );
    } else {
      sockets[port].post(new noflo.IP("data", value));
    }
  }
  const ip = await received;
  return ip.data;
};

describe("Rectangle command emitters", () => {
  it("FillRect builds a typed command", async () => {
    const c = getFillRect();
    try {
      const data = await run(c, "fillrect", {
        point: { type: "point", x: 1, y: 2 },
        width: 10,
        height: 20,
      });
      assert.deepEqual(data, {
        type: "fillrect",
        point: { type: "point", x: 1, y: 2 },
        width: 10,
        height: 20,
      });
    } finally {
      await c.shutdown();
    }
  });
  it("StrokeRect builds a typed command", async () => {
    const c = getStrokeRect();
    try {
      const data = await run(c, "strokerect", {
        point: { type: "point", x: 0, y: 0 },
        width: 5,
        height: 5,
      });
      assert.deepEqual(data, {
        type: "strokerect",
        point: { type: "point", x: 0, y: 0 },
        width: 5,
        height: 5,
      });
    } finally {
      await c.shutdown();
    }
  });
  it("ClearRect builds a typed command", async () => {
    const c = getClearRect();
    try {
      const data = await run(c, "clearrect", {
        point: { type: "point", x: 3, y: 3 },
        width: 4,
        height: 4,
      });
      assert.deepEqual(data, {
        type: "clearrect",
        point: { type: "point", x: 3, y: 3 },
        width: 4,
        height: 4,
      });
    } finally {
      await c.shutdown();
    }
  });
});

describe("Style command emitters", () => {
  it("StrokeStyle builds a typed command", async () => {
    const c = getStrokeStyle();
    try {
      const data = await run(c, "strokestyle", { style: "#00ff00" });
      assert.deepEqual(data, { type: "strokeStyle", value: "#00ff00" });
    } finally {
      await c.shutdown();
    }
  });
});

describe("Shape commands", () => {
  it("MakePath emits one path per activation", async () => {
    const c = getMakePath();
    const first = noflo.internalSocket.createSocket();
    const second = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.items.attach(first, 0);
    c.inPorts.items.attach(second, 1);
    c.outPorts.path.attach(outSocket);
    try {
      // Each item post is its own activation (synchronous bursts)
      const firstPath = nextData(outSocket);
      first.post(new noflo.IP("data", { type: "point", x: 0, y: 0 }, /** @type {any} */ ({ index: 0 })));
      const firstIp = await firstPath;
      assert.deepEqual(firstIp.data, {
        type: "path",
        items: [{ type: "point", x: 0, y: 0 }],
      });
      const secondPath = nextData(outSocket);
      second.post(new noflo.IP("data", { type: "point", x: 5, y: 5 }, /** @type {any} */ ({ index: 1 })));
      const secondIp = await secondPath;
      assert.deepEqual(secondIp.data, {
        type: "path",
        items: [{ type: "point", x: 5, y: 5 }],
      });
    } finally {
      await c.shutdown();
    }
  });
  it("MakePath passes point arrays through for Draw to recurse into", async () => {
    const c = getMakePath();
    const items = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.items.attach(items, 0);
    c.outPorts.path.attach(outSocket);
    try {
      const received = nextData(outSocket);
      items.post(
        new noflo.IP(
          "data",
          [
            { type: "point", x: 0, y: 0 },
            { type: "point", x: 5, y: 5 },
          ],
          /** @type {any} */ ({ index: 0 }),
        ),
      );
      const ip = await received;
      assert.deepEqual(ip.data, {
        type: "path",
        items: [
          [
            { type: "point", x: 0, y: 0 },
            { type: "point", x: 5, y: 5 },
          ],
        ],
      });
    } finally {
      await c.shutdown();
    }
  });
  it("Stroke builds a command with optional controls and closepath default", async () => {
    const c = getStroke();
    const items = noflo.internalSocket.createSocket();
    const strokestyle = noflo.internalSocket.createSocket();
    const closepath = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.items.attach(items, 0);
    c.inPorts.strokestyle.attach(strokestyle);
    c.inPorts.closepath.attach(closepath);
    c.outPorts.stroke.attach(outSocket);
    try {
      const received = nextData(outSocket);
      // Controls first, then the completing item
      strokestyle.post(new noflo.IP("data", "blue"));
      closepath.post(new noflo.IP("data", true));
      items.post(new noflo.IP("data", { type: "circle", center: { type: "point", x: 1, y: 1 }, radius: 2 }, /** @type {any} */ ({ index: 0 })));
      const ip = await received;
      assert.deepEqual(ip.data, {
        type: "stroke",
        items: [{ type: "circle", center: { type: "point", x: 1, y: 1 }, radius: 2 }],
        strokestyle: "blue",
        closepath: true,
      });
    } finally {
      await c.shutdown();
    }
  });
});

describe("Transform and Recurse", () => {
  it("Transform builds a command from received operations", async () => {
    const c = getTransform();
    const items = noflo.internalSocket.createSocket();
    const translate = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.items.attach(items, 0);
    c.inPorts.translate.attach(translate);
    c.outPorts.transform.attach(outSocket);
    try {
      const received = nextData(outSocket);
      translate.post(new noflo.IP("data", { type: "point", x: 10, y: 20 }));
      items.post(new noflo.IP("data", { type: "circle", radius: 1 }, /** @type {any} */ ({ index: 0 })));
      const ip = await received;
      assert.deepEqual(ip.data, {
        type: "transform",
        items: [{ type: "circle", radius: 1 }],
        translate: { type: "point", x: 10, y: 20 },
      });
    } finally {
      await c.shutdown();
    }
  });
  it("Recurse collects recursables and emits on count", async () => {
    const c = getRecurse();
    const items = noflo.internalSocket.createSocket();
    const count = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.recursables.attach(items, 0);
    c.inPorts.count.attach(count);
    c.outPorts.recurse.attach(outSocket);
    try {
      const received = nextData(outSocket);
      items.post(new noflo.IP("data", { type: "transform", translate: { type: "point", x: 1, y: 1 } }, /** @type {any} */ ({ index: 0 })));
      const ip = await received;
      // Emission on recursable arrival carries the null count, like 1.x
      assert.deepEqual(ip.data, {
        type: "recurse",
        recursables: [{ type: "transform", translate: { type: "point", x: 1, y: 1 } }],
        count: null,
      });
      const onCount = nextData(outSocket);
      count.post(new noflo.IP("data", 3));
      const countIp = await onCount;
      assert.deepEqual(countIp.data, {
        type: "recurse",
        recursables: [{ type: "transform", translate: { type: "point", x: 1, y: 1 } }],
        count: 3,
      });
    } finally {
      await c.shutdown();
    }
  });
  it("Recurse keeps state per scope", async () => {
    const c = getRecurse();
    const first = noflo.internalSocket.createSocket();
    const second = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.recursables.attach(first, 0);
    c.inPorts.recursables.attach(second, 0);
    c.outPorts.recurse.attach(outSocket);
    try {
      const received = nextData(outSocket);
      first.post(
        new noflo.IP(
          "data",
          { type: "transform", translate: { type: "point", x: 1, y: 1 } },
          { index: 0, scope: "a" },
        ),
      );
      const ip = await received;
      assert.deepEqual(ip.data.recursables, [
        { type: "transform", translate: { type: "point", x: 1, y: 1 } },
      ]);
      const receivedB = nextData(outSocket);
      second.post(
        new noflo.IP(
          "data",
          { type: "transform", translate: { type: "point", x: 2, y: 2 } },
          { index: 0, scope: "b" },
        ),
      );
      const ipB = await receivedB;
      // Scope b has its own buffer, not scope a's
      assert.deepEqual(ipB.data.recursables, [
        { type: "transform", translate: { type: "point", x: 2, y: 2 } },
      ]);
    } finally {
      await c.shutdown();
    }
  });
});

describe("DrawImage", () => {
  it("builds a command with the destpoint default", async () => {
    const c = getDrawImage();
    const canvas = createCanvas(4, 4);
    try {
      const data = await run(c, "drawimage", { image: canvas });
      assert.deepEqual(data, {
        type: "drawimage",
        image: canvas,
        destpoint: { x: 0, y: 0 },
      });
    } finally {
      await c.shutdown();
    }
  });
  it("includes destrect and sourcerect when received", async () => {
    const c = getDrawImage();
    const canvas = createCanvas(4, 4);
    try {
      const data = await run(c, "drawimage", {
        destrect: { point: { type: "point", x: 0, y: 0 }, width: 8, height: 8 },
        sourcerect: { point: { type: "point", x: 1, y: 1 }, width: 2, height: 2 },
        image: canvas,
      });
      assert.deepEqual(data, {
        type: "drawimage",
        image: canvas,
        destpoint: { x: 0, y: 0 },
        destrect: { point: { type: "point", x: 0, y: 0 }, width: 8, height: 8 },
        sourcerect: { point: { type: "point", x: 1, y: 1 }, width: 2, height: 2 },
      });
    } finally {
      await c.shutdown();
    }
  });
});
