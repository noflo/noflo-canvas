/** Minimal typing for the subset of the pureimage API the node engine uses. */
declare module "pureimage" {
  /** The Web Canvas 2D subset the drawing components rely on. */
  export interface BitmapContext {
    beginPath(): void;
    closePath(): void;
    moveTo(x: number, y: number): void;
    lineTo(x: number, y: number): void;
    bezierCurveTo(
      control1x: number,
      control1y: number,
      control2x: number,
      control2y: number,
      endx: number,
      endy: number,
    ): void;
    arc(
      x: number,
      y: number,
      radius: number,
      startAngle: number,
      endAngle: number,
      counterclockwise?: boolean,
    ): void;
    fill(): void;
    stroke(): void;
    fillRect(x: number, y: number, width: number, height: number): void;
    strokeRect(x: number, y: number, width: number, height: number): void;
    clearRect(x: number, y: number, width: number, height: number): void;
    drawImage(image: unknown, ...args: number[]): void;
    translate(x: number, y: number): void;
    rotate(angle: number): void;
    scale(x: number, y: number): void;
    save(): void;
    restore(): void;
    getImageData(
      x: number,
      y: number,
      width: number,
      height: number,
    ): { data: Uint8ClampedArray };
    fillStyle: string;
    strokeStyle: string;
    lineWidth: number;
  }
  export interface Bitmap {
    width: number;
    height: number;
    data: Uint8ClampedArray;
    getContext(mode: "2d"): import("pureimage").BitmapContext;
  }
  import type { Readable, Writable } from "node:stream";
  export function make(width: number, height: number): Bitmap;
  export function encodePNGToStream(
    bitmap: Bitmap,
    stream: Writable,
  ): Promise<void>;
  export function encodeJPEGToStream(
    bitmap: Bitmap,
    stream: Writable,
  ): Promise<void>;
  export function decodePNGFromStream(stream: Readable): Promise<Bitmap>;
  export function decodeJPEGFromStream(stream: Readable): Promise<Bitmap>;
}
