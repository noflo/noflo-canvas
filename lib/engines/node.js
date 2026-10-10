/**
 * Node.js canvas engine: pureimage, pure JavaScript, no install scripts or
 * binaries.
 *
 * The engine contract shared with `browser.js`:
 *
 * - `createCanvas(width, height)` returns a canvas object carrying
 *   `width`/`height` and a Web Canvas 2D `getContext("2d")` context. Canvas
 *   objects flow through graph ports as data.
 * - `canvasToPng(canvas)` / `canvasToJpeg(canvas)` encode the canvas to
 *   image bytes.
 * - `decodeImage(bytes)` decodes PNG or JPEG bytes into a drawable canvas
 *   object.
 *
 * Components speak the Web Canvas 2D API subset directly on the context;
 * only these three creation/encode/decode operations differ per platform.
 *
 * The public contract is stream-free: bytes in, bytes out. pureimage works
 * over Node.js streams internally, bridged here; if streaming ever becomes
 * part of the contract, `node:stream` web interop keeps the boundary
 * Web-standard.
 */
import { Readable, Writable } from "node:stream";
import {
  decodeJPEGFromStream,
  decodePNGFromStream,
  encodeJPEGToStream,
  encodePNGToStream,
  make,
} from "pureimage";

/**
 * A canvas object: dimensions plus a Web Canvas 2D context providing the
 * drawing subset. Native browser canvas classes and the node engine's
 * pureimage bitmap both satisfy this structurally.
 * @typedef {import("./types.js").CanvasLike} CanvasLike
 */

/**
 * Creates a canvas with the given dimensions.
 * @param {number} width
 * @param {number} height
 * @returns {CanvasLike}
 */
export function createCanvas(width, height) {
  const bitmap = make(width, height);
  const context = bitmap.getContext("2d");
  // pureimage's drawImage takes the destination rectangle before the
  // source rectangle, unlike the Web Canvas API; shim the argument order
  // so components can speak the Web API
  const wrapped = new Proxy(context, {
    get(target, prop) {
      if (prop === "drawImage") {
        return (
          /** @param {unknown} image @param {number[]} args */
          (image, ...args) => {
            if (args.length <= 4) {
              return Reflect.apply(
                /** @type {Function} */ (target.drawImage),
                target,
                [image, ...args],
              );
            }
            // Web: (sx, sy, sw, sh, dx, dy, dw, dh) -> pureimage: (dx, dy, dw, dh, sx, sy, sw, sh)
            const [sx, sy, sw, sh, dx, dy, dw, dh] = args;
            return Reflect.apply(
              /** @type {Function} */ (target.drawImage),
              target,
              [image, dx, dy, dw, dh, sx, sy, sw, sh],
            );
          }
        );
      }
      const value = Reflect.get(target, prop);
      return typeof value === "function"
        ? /** @type {(...args: unknown[]) => unknown} */ (value).bind(target)
        : value;
    },
    set(target, prop, value) {
      return Reflect.set(target, prop, value);
    },
  });
  bitmap.getContext = () => wrapped;
  return bitmap;
}

/**
 * Encodes a bitmap through a pureimage stream encoder, collecting the
 * output into bytes.
 * @param {import("pureimage").Bitmap} canvas
 * @param {(bitmap: import("pureimage").Bitmap, stream: Writable) => Promise<void>} encodeFn
 * @returns {Promise<Uint8Array>}
 */
async function encodeBitmap(canvas, encodeFn) {
  /** @type {Uint8Array[]} */
  const chunks = [];
  const stream = new Writable({
    /** @param {Buffer} chunk @param {string} _encoding @param {(err?: Error | null) => void} callback */
    write(chunk, _encoding, callback) {
      chunks.push(chunk);
      callback();
    },
  });
  await encodeFn(canvas, stream);
  const length = chunks.reduce((sum, chunk) => sum + chunk.length, 0);
  const bytes = new Uint8Array(length);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  return bytes;
}

/**
 * Encodes a canvas as PNG bytes.
 * @param {CanvasLike} canvas
 * @returns {Promise<Uint8Array>}
 */
export function canvasToPng(canvas) {
  return encodeBitmap(
    /** @type {import("pureimage").Bitmap} */ (/** @type {unknown} */ (canvas)),
    encodePNGToStream,
  );
}

/**
 * Encodes a canvas as JPEG bytes.
 * @param {CanvasLike} canvas
 * @returns {Promise<Uint8Array>}
 */
export function canvasToJpeg(canvas) {
  return encodeBitmap(
    /** @type {import("pureimage").Bitmap} */ (/** @type {unknown} */ (canvas)),
    encodeJPEGToStream,
  );
}

/**
 * Decodes PNG or JPEG bytes into a drawable canvas object.
 * @param {Uint8Array} bytes
 * @returns {Promise<CanvasLike>}
 */
export async function decodeImage(bytes) {
  try {
    return await decodePNGFromStream(Readable.from([bytes]));
  } catch (pngError) {
    try {
      return await decodeJPEGFromStream(Readable.from([bytes]));
    } catch {
      throw new Error(
        `Unable to decode image bytes: ${pngError instanceof Error ? pngError.message : String(pngError)}`,
      );
    }
  }
}
