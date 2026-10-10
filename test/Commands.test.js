import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";
import { getComponent as getColorArrayToCss } from "../components/ColorArrayToCss.js";
import { getComponent as getFill } from "../components/Fill.js";
import { getComponent as getFillStyle } from "../components/FillStyle.js";
import { getComponent as getGroup } from "../components/Group.js";
import { getComponent as getLineWidth } from "../components/LineWidth.js";
import { getComponent as getMakeArc } from "../components/MakeArc.js";
import { getComponent as getMakeBezierCurve } from "../components/MakeBezierCurve.js";
import { getComponent as getMakeCircle } from "../components/MakeCircle.js";
import { getComponent as getMakeColor } from "../components/MakeColor.js";
import { getComponent as getMakeGrid } from "../components/MakeGrid.js";
import { getComponent as getMakeIncrement } from "../components/MakeIncrement.js";
import { getComponent as getMakeRandom } from "../components/MakeRandom.js";
import { getComponent as getMakeRange } from "../components/MakeRange.js";
import { getComponent as getMakeRectangle } from "../components/MakeRectangle.js";
import { getComponent as getMakeRectangleAspectRatio } from "../components/MakeRectangleAspectRatio.js";
import { getComponent as getMakeRGBColor } from "../components/MakeRGBColor.js";

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
 * Wires a component, sends one IP per given input, and returns the first
 * data value from the outport.
 * @param {import("@noflo/noflo").Component} c
 * @param {string} _inPort Unused; inputs keys name the ports
 * @param {string} outPort
 * @param {Record<string, any>} inputs
 * @returns {Promise<any>}
 */
const runComponent = async (c, _inPort, outPort, inputs) => {
  const outSocket = noflo.internalSocket.createSocket();
  c.outPorts[outPort].attach(outSocket);
  const received = nextData(outSocket);
  // Attach every socket before posting anything: an unattached optional
  // port makes hasData vacuously true, which would fire early
  /** @type {Record<string, import("@noflo/noflo").internalSocket.InternalSocket>} */
  const sockets = {};
  for (const port of Object.keys(inputs)) {
    const socket = noflo.internalSocket.createSocket();
    c.inPorts[port].attach(socket);
    sockets[port] = socket;
  }
  for (const [port, value] of Object.entries(inputs)) {
    sockets[port].post(new noflo.IP("data", value));
  }
  const ip = await received;
  return ip.data;
};

describe("Make family", () => {
  it("MakeRectangle builds a typed rectangle", async () => {
    const c = getMakeRectangle();
    try {
      const data = await runComponent(c, "point", "rectangle", {
        point: { type: "point", x: 1, y: 2 },
        width: 10,
        height: 20,
      });
      assert.deepEqual(data, {
        type: "rectangle",
        point: { type: "point", x: 1, y: 2 },
        width: 10,
        height: 20,
      });
    } finally {
      await c.shutdown();
    }
  });
  it("MakeRectangleAspectRatio derives the missing dimension", async () => {
    const c = getMakeRectangleAspectRatio();
    try {
      const data = await runComponent(c, "width", "rectangle", {
        width: -1,
        height: 100,
        origwidth: 200,
        origheight: 100,
      });
      assert.equal(data.type, "rectangle");
      assert.equal(data.width, 200);
      assert.equal(data.height, 100);
      assert.deepEqual(data.point, { type: "point", x: 0, y: 0 });
    } finally {
      await c.shutdown();
    }
  });
  it("MakeCircle builds a typed circle", async () => {
    const c = getMakeCircle();
    try {
      const data = await runComponent(c, "center", "circle", {
        center: { type: "point", x: 5, y: 5 },
        radius: 3,
      });
      assert.deepEqual(data, {
        type: "circle",
        center: { type: "point", x: 5, y: 5 },
        radius: 3,
      });
    } finally {
      await c.shutdown();
    }
  });
  it("MakeArc falls back to the reverse default", async () => {
    const c = getMakeArc();
    try {
      const data = await runComponent(c, "center", "arc", {
        center: { type: "point", x: 0, y: 0 },
        radius: 2,
        start: 0,
        end: Math.PI,
      });
      assert.equal(data.type, "arc");
      assert.equal(data.reverse, false);
    } finally {
      await c.shutdown();
    }
  });
  it("MakeBezierCurve builds a typed curve", async () => {
    const c = getMakeBezierCurve();
    try {
      const data = await runComponent(c, "control1", "beziercurve", {
        control1: { type: "point", x: 0, y: 0 },
        control2: { type: "point", x: 1, y: 1 },
        end: { type: "point", x: 2, y: 0 },
      });
      assert.deepEqual(data, {
        type: "beziercurve",
        control1: { type: "point", x: 0, y: 0 },
        control2: { type: "point", x: 1, y: 1 },
        end: { type: "point", x: 2, y: 0 },
      });
    } finally {
      await c.shutdown();
    }
  });
  it("MakeColor formats an HSL color", async () => {
    const c = getMakeColor();
    try {
      const data = await runComponent(c, "hue", "color", {
        hue: 120,
        saturation: 50,
        lightness: 40,
      });
      assert.equal(data, "hsl(120, 50%, 40%)");
    } finally {
      await c.shutdown();
    }
  });
  it("MakeRGBColor formats an RGBA color", async () => {
    const c = getMakeRGBColor();
    try {
      const data = await runComponent(c, "red", "color", {
        // Optional reads participate only when present before the
        // completing post, so alpha comes first
        alpha: 0.5,
        red: 10.4,
        green: 20,
        blue: 30,
      });
      assert.equal(data, "rgba(10, 20, 30, 0.5)");
    } finally {
      await c.shutdown();
    }
  });
  it("ColorArrayToCss formats a hex string", async () => {
    const c = getColorArrayToCss();
    try {
      const data = await runComponent(c, "in", "out", { in: [255, 0, 15] });
      assert.equal(data, "#ff000f");
    } finally {
      await c.shutdown();
    }
  });
  it("MakeIncrement counts up and down", async () => {
    const c = getMakeIncrement();
    try {
      const up = await runComponent(c, "from", "range", { from: 0, to: 3 });
      assert.deepEqual(up, [0, 1, 2, 3]);
      const down = await runComponent(c, "from", "range", { from: 2, to: 0 });
      assert.deepEqual(down, [2, 1, 0]);
    } finally {
      await c.shutdown();
    }
  });
  it("MakeRange spreads evenly", async () => {
    const c = getMakeRange();
    try {
      const data = await runComponent(c, "from", "range", {
        from: 0,
        to: 10,
        count: 3,
      });
      assert.deepEqual(data, [0, 5, 10]);
    } finally {
      await c.shutdown();
    }
  });
  it("MakeRandom stays within bounds", async () => {
    const c = getMakeRandom();
    try {
      const data = await runComponent(c, "min", "numbers", {
        min: 5,
        max: 10,
        count: 4,
      });
      assert.equal(data.length, 4);
      for (const value of data) {
        assert.ok(value >= 5 && value <= 10);
      }
    } finally {
      await c.shutdown();
    }
  });
  it("MakeGrid crosses the coordinate arrays", async () => {
    const c = getMakeGrid();
    try {
      const data = await runComponent(c, "x", "points", {
        x: [0, 1],
        y: [10, 20],
      });
      assert.deepEqual(data, [
        { type: "point", x: 0, y: 10 },
        { type: "point", x: 1, y: 10 },
        { type: "point", x: 0, y: 20 },
        { type: "point", x: 1, y: 20 },
      ]);
    } finally {
      await c.shutdown();
    }
  });
  it("MakeGrid rejects non-array coordinates", async () => {
    const c = getMakeGrid();
    const x = noflo.internalSocket.createSocket();
    const y = noflo.internalSocket.createSocket();
    const errorSocket = noflo.internalSocket.createSocket();
    c.inPorts.x.attach(x);
    c.inPorts.y.attach(y);
    c.outPorts.error.attach(errorSocket);
    try {
      const errored = nextData(errorSocket);
      x.post(new noflo.IP("data", 1));
      y.post(new noflo.IP("data", [1, 2]));
      const ip = await errored;
      assert.ok(ip.data instanceof Error);
    } finally {
      await c.shutdown();
    }
  });
});

describe("Command emitters", () => {
  it("FillStyle builds a typed command", async () => {
    const c = getFillStyle();
    try {
      const data = await runComponent(c, "style", "fillstyle", {
        style: "rgb(1, 2, 3)",
      });
      assert.deepEqual(data, { type: "fillStyle", value: "rgb(1, 2, 3)" });
    } finally {
      await c.shutdown();
    }
  });
  it("LineWidth builds a typed command", async () => {
    const c = getLineWidth();
    try {
      const data = await runComponent(c, "width", "linewidth", { width: 4 });
      assert.deepEqual(data, { type: "lineWidth", value: 4 });
    } finally {
      await c.shutdown();
    }
  });
  it("Fill emits one command per activation", async () => {
    const c = getFill();
    const first = noflo.internalSocket.createSocket();
    const second = noflo.internalSocket.createSocket();
    const fillstyle = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.items.attach(first, 0);
    c.inPorts.items.attach(second, 1);
    c.inPorts.fillstyle.attach(fillstyle);
    c.outPorts.fill.attach(outSocket);
    try {
      // Controls first: they buffer for subsequent activations
      fillstyle.post(new noflo.IP("data", "red"));
      // Each item post is its own activation (synchronous bursts)
      const firstCommand = nextData(outSocket);
      first.post(
        new noflo.IP(
          "data",
          { type: "circle", radius: 1 },
          /** @type {any} */ ({ index: 0 }),
        ),
      );
      const firstIp = await firstCommand;
      assert.deepEqual(firstIp.data, {
        type: "fill",
        items: [{ type: "circle", radius: 1 }],
        fillstyle: "red",
      });
      // Arrays pass through for Draw to recurse into
      const secondCommand = nextData(outSocket);
      second.post(
        new noflo.IP(
          "data",
          [{ type: "rectangle", width: 2, height: 2 }],
          /** @type {any} */ ({ index: 1 }),
        ),
      );
      const secondIp = await secondCommand;
      assert.deepEqual(secondIp.data, {
        type: "fill",
        items: [[{ type: "rectangle", width: 2, height: 2 }]],
        fillstyle: "red",
      });
    } finally {
      await c.shutdown();
    }
  });
  it("Group flattens arrays and scalars once all indexes have data", async () => {
    const c = getGroup();
    const first = noflo.internalSocket.createSocket();
    const second = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.items.attach(first, 0);
    c.inPorts.items.attach(second, 1);
    c.outPorts.group.attach(outSocket);
    try {
      const received = nextData(outSocket);
      first.post(
        new noflo.IP(
          "data",
          [{ type: "point", x: 0, y: 0 }],
          /** @type {any} */ ({ index: 0 }),
        ),
      );
      const early = received.then(
        () => {
          throw new Error("Fired before all indexes had data");
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
      second.post(
        new noflo.IP(
          "data",
          { type: "point", x: 1, y: 1 },
          /** @type {any} */ ({ index: 1 }),
        ),
      );
      const ip = await received;
      assert.deepEqual(ip.data, [
        { type: "point", x: 0, y: 0 },
        { type: "point", x: 1, y: 1 },
      ]);
    } finally {
      await c.shutdown();
    }
  });
});
