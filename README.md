# noflo-canvas — Canvas 2D to NoFlo

Canvas 2D drawing components for [NoFlo](https://noflojs.org): a vocabulary of typed drawing commands (points, shapes, paths, fills, strokes, transforms) and a `Draw` component that interprets them onto a canvas.

Part of the NoFlo 2.x component library family. Requires Node.js >= 22, and runs on Deno and Bun as well.

## Isomorphic by engine split

All components are environment-agnostic: graphs written with `canvas/*` components run unmodified in Node.js and browsers. The one environment difference — how a canvas is created and encoded — lives behind the package's conditional exports:

    import { createCanvas, canvasToPng, decodeImage } from "@noflo/canvas/engine";

- **Browsers** (`browser` condition): native `OffscreenCanvas`/`HTMLCanvasElement`, zero dependencies, GPU-accelerated.
- **Node.js** (`node` condition): [pureimage](https://npmjs.com/package/pureimage) — pure JavaScript, no compilation, no install scripts, no binaries.

Components import the engine through package self-reference, so plain Node.js works without any build step, and bundlers (esbuild and friends) tree-shake the unused engine away when bundling for the browser.

The canvas objects flowing through graph ports share one structural contract: `width`, `height`, and a Web Canvas 2D `getContext("2d")` context covering the drawing subset these components use.

## Usage

    npm install @noflo/canvas

Component identifiers in graphs are `canvas/<Component>`, for example `canvas/Draw`. See `noflo.json` for the machine-readable component manifest.

## Components

- **canvas/CreateCanvas** — makes a canvas with the given `width`/`height`
- **canvas/SavePNG**, **canvas/SaveJPEG** — encode a canvas to image bytes (`Uint8Array`); unlike the 1.x pair of components, one isomorphic component handles both environments
- **Drawing primitives**: `canvas/MakePoint`, `canvas/MakeRectangle`, `canvas/MakeRectangleAspectRatio`, `canvas/MakeCircle`, `canvas/MakeArc`, `canvas/MakeBezierCurve`, `canvas/MakePath`
- **Colors**: `canvas/MakeColor` (HSL), `canvas/MakeRGBColor` (RGB), `canvas/ColorArrayToCss`
- **Number generators**: `canvas/MakeRange`, `canvas/MakeIncrement`, `canvas/MakeRandom`, `canvas/MakeGrid` (x × y coordinate arrays → grid of points)
- **Command builders**: `canvas/FillRect`, `canvas/StrokeRect`, `canvas/ClearRect`, `canvas/FillStyle`, `canvas/StrokeStyle`, `canvas/LineWidth`, `canvas/Fill`, `canvas/Stroke`, `canvas/DrawImage`, `canvas/Transform`, `canvas/Group`, `canvas/Recurse`
- **canvas/Draw** — interprets received commands onto a canvas; commands buffer in a per-scope slot buffer and a `tick` triggers a drawing pass, or `drawevery` draws on every command batch

Components accept one item per activation; collections flow as streams or arrays where the contract is consistently array-based (`MakeGrid`, `ColorArrayToCss`).

## Development

    npm test

The test suite runs TypeScript checks, Biome lint, fbp-spec cases from `spec/`, and `node:test` suites from `test/`.

## License

MIT
