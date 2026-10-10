/**
 * The engine contract, expressed structurally so components and tests type
 * against the same shape on every platform.
 *
 * A canvas is anything with dimensions and a Web Canvas 2D context providing
 * the method subset the drawing components use: the native browser canvas
 * classes and the pureimage bitmap both satisfy it structurally.
 */

/**
 * The Web Canvas 2D method subset the drawing components rely on.
 * @typedef {object} EngineContext
 * @property {string} fillStyle
 * @property {string} strokeStyle
 * @property {number} lineWidth
 * @property {() => void} beginPath
 * @property {() => void} closePath
 * @property {(x: number, y: number) => void} moveTo
 * @property {(x: number, y: number) => void} lineTo
 * @property {(control1x: number, control1y: number, control2x: number, control2y: number, endx: number, endy: number) => void} bezierCurveTo
 * @property {(x: number, y: number, radius: number, startAngle: number, endAngle: number, counterclockwise?: boolean) => void} arc
 * @property {() => void} fill
 * @property {() => void} stroke
 * @property {(x: number, y: number, width: number, height: number) => void} fillRect
 * @property {(x: number, y: number, width: number, height: number) => void} strokeRect
 * @property {(x: number, y: number, width: number, height: number) => void} clearRect
 * @property {(image: CanvasLike, ...rest: number[]) => void} drawImage Draws the image at `(dx, dy)`, scaled to `(dw, dh)`, or with the Web API 9-argument source/destination form
 * @property {(x: number, y: number) => void} translate
 * @property {(angle: number) => void} rotate
 * @property {(x: number, y: number) => void} scale
 * @property {() => void} save
 * @property {() => void} restore
 * @property {(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number) => { addColorStop(offset: number, color: string): void }} createRadialGradient
 * @property {(x: number, y: number, width: number, height: number) => { data: Uint8ClampedArray }} getImageData
 * @property {(imageData: { data: Uint8ClampedArray, width: number, height: number }, dx: number, dy: number) => void} putImageData
 */

/**
 * A canvas object: dimensions plus a 2D context. Canvas objects flow
 * through graph ports as data.
 * @typedef {object} CanvasLike
 * @property {number} width
 * @property {number} height
 * @property {(mode: "2d") => EngineContext} getContext
 */

export {};
