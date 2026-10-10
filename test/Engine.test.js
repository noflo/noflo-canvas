import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  canvasToJpeg,
  canvasToPng,
  createCanvas,
  decodeImage,
} from "../lib/engines/node.js";

describe("node canvas engine", () => {
  it("creates canvases with a 2D context", () => {
    const canvas = createCanvas(10, 5);
    assert.equal(canvas.width, 10);
    assert.equal(canvas.height, 5);
    const ctx = canvas.getContext("2d");
    assert.equal(typeof ctx.fillRect, "function");
    assert.equal(typeof ctx.drawImage, "function");
    assert.equal(typeof ctx.translate, "function");
  });
  it("round-trips PNG through decodeImage", async () => {
    const canvas = createCanvas(4, 6);
    const ctx = canvas.getContext("2d");
    ctx.fillStyle = "rgb(255, 0, 0)";
    ctx.fillRect(0, 0, 4, 6);
    const png = await canvasToPng(canvas);
    // PNG magic number
    assert.equal(png[0], 0x89);
    assert.equal(png[1], 0x50);
    const decoded = await decodeImage(png);
    assert.equal(decoded.width, 4);
    assert.equal(decoded.height, 6);
  });
  it("round-trips JPEG through decodeImage", async () => {
    const canvas = createCanvas(4, 4);
    const jpeg = await canvasToJpeg(canvas);
    // JPEG magic number
    assert.equal(jpeg[0], 0xff);
    assert.equal(jpeg[1], 0xd8);
    const decoded = await decodeImage(jpeg);
    assert.equal(decoded.width, 4);
    assert.equal(decoded.height, 4);
  });
  it("draws decoded images onto canvases", async () => {
    const source = createCanvas(2, 2);
    const ctx = source.getContext("2d");
    ctx.fillStyle = "rgb(0, 0, 255)";
    ctx.fillRect(0, 0, 2, 2);
    const png = await canvasToPng(source);
    const decoded = await decodeImage(png);
    const target = createCanvas(4, 4);
    const targetCtx = target.getContext("2d");
    targetCtx.drawImage(/** @type {never} */ (decoded), 0, 0);
    const png2 = await canvasToPng(target);
    const roundTripped = await decodeImage(png2);
    const data = roundTripped.getContext("2d").getImageData(0, 0, 4, 4);
    // Top-left pixel should be blue
    assert.equal(data.data[0], 0);
    assert.equal(data.data[1], 0);
    assert.equal(data.data[2], 255);
  });
});
