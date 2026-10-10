/**
 * Browser canvas engine: Web-standard canvas APIs, no dependencies.
 *
 * The engine contract shared with `node.js`:
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
 */

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
  if (typeof OffscreenCanvas === "function") {
    return /** @type {CanvasLike} */ (/** @type {unknown} */ (new OffscreenCanvas(width, height)));
  }
  const canvas = document.createElement("canvas");
  canvas.width = width;
  canvas.height = height;
  return /** @type {CanvasLike} */ (/** @type {unknown} */ (canvas));
}

/**
 * Encodes a canvas through the Blob API.
 * @param {CanvasLike} canvas
 * @param {string} type MIME type, e.g. "image/png"
 * @returns {Promise<Uint8Array>}
 */
async function encodeBlob(canvas, type) {
  /** @type {Blob} */
  let blob;
  if (
    typeof OffscreenCanvas === "function" &&
    canvas instanceof OffscreenCanvas
  ) {
    blob = await canvas.convertToBlob({ type });
  } else if (
    typeof HTMLCanvasElement === "function" &&
    canvas instanceof HTMLCanvasElement
  ) {
    blob = await new Promise((resolve, reject) => {
      canvas.toBlob(
        /** @param {Blob | null} result */
        (result) => {
          if (result) {
            resolve(result);
          } else {
            reject(new Error("Canvas encoding failed"));
          }
        },
        type,
      );
    });
  } else {
    throw new Error("Canvas object cannot be encoded in the browser engine");
  }
  return new Uint8Array(await blob.arrayBuffer());
}

/**
 * Encodes a canvas as PNG bytes.
 * @param {CanvasLike} canvas
 * @returns {Promise<Uint8Array>}
 */
export function canvasToPng(canvas) {
  return encodeBlob(canvas, "image/png");
}

/**
 * Encodes a canvas as JPEG bytes.
 * @param {CanvasLike} canvas
 * @returns {Promise<Uint8Array>}
 */
export function canvasToJpeg(canvas) {
  return encodeBlob(canvas, "image/jpeg");
}

/**
 * Decodes PNG or JPEG bytes into a drawable canvas object.
 * @param {Uint8Array} bytes
 * @returns {Promise<ImageBitmap>}
 */
export async function decodeImage(bytes) {
  const blob = new Blob([/** @type {BlobPart} */ (bytes)]);
  return createImageBitmap(blob);
}
