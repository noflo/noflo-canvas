# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0-alpha.2] - 2026-10-11

### Changed

- Package renamed to `@noflo/canvas`; the version resets to the 2.x generation (2.0.0-alpha.1) for the fresh package name. Component addressing is unchanged — library IDs derive identically from the scoped name, so component and graph names stay the same. The old `noflo-canvas` will be deprecated with a pointer once 2.x reaches stable
- Migrated to NoFlo 2.x: components now depend on `@noflo/noflo` ^2.0.0 instead of the unscoped `noflo` 1.x package; components export a named `getComponent`
- Package is now plain ESM with no build step; supported runtime is Node.js >= 22 (components also run under Deno and Bun); indentation normalized to spaces per the repository EditorConfig
- Replaced the `canvas` dependency (node-canvas, a compiling native module) with an engine split behind conditional exports: components import `@noflo/canvas/engine`, which resolves to native `OffscreenCanvas`/`HTMLCanvasElement` in browsers and to `pureimage` (pure JavaScript, no install scripts) in Node.js. Component addressing is unchanged and graphs are now isomorphic — the 1.x `CreateCanvas-node`, `SavePNG-node`, and `SaveJPEG-node` variants are gone, merged into single components that work in both environments
- `canvas/SavePNG` and `canvas/SaveJPEG` emit image bytes (`Uint8Array`) instead of the 1.x data URL string (browser) or a written file path (Node.js). Writing encoded images to files is a job for `@noflo/filesystem` components
- Removed the `noflo-helper-arrayable` dependency: all Make* and command components accept one item per activation and emit one result per activation. `canvas/MakeGrid` keeps a consistently array-in/array-out contract (x and y coordinate arrays → array of points); its 1.x scalar inputs are replaced by single-element arrays
- `canvas/Fill`, `canvas/Stroke`, and `canvas/MakePath` collect the shapes received in one activation instead of accumulating shapes across the scope lifetime as the 1.x helper did; a stream of shapes produces a stream of fill/stroke commands, and arrays pass through for `canvas/Draw` to recurse into
- `canvas/MakeRectangleAspectRatio` requires `origheight`: the 1.x component declared it optional but its compute gate demanded it
- `canvas/Transform` operations apply in a fixed order (`translate`, `rotate`, `scale`/`scaleboth`); 1.x applied them in data arrival order
- `canvas/Draw` command buffers are per-scope as in 1.x; the `drawevery` and `clearevery` controls keep their defaults, delivered by the network
- Removed the 1.x example graphs: they wire `dom/GetAttribute` (noflo-dom is not migrated yet) and trivial `core/Split`/`core/Repeat` compositions

### Fixed

- `canvas/Draw` now dispatches `fillrect`, `strokerect`, and `clearrect` commands: the 1.x interpreter looked handlers up case-sensitively against camelCase method names, so these command types were silently ignored
- `canvas/Draw` restores the line width after a `stroke` command carrying `linewidth`: the 1.x interpreter read the width back from a misspelled property, so the stroke width leaked into all later commands
- `canvas/Draw` completes its processing context on every path after reading the canvas; a bare early return left the activation pending and hung `shutdown()`

### Added

- `test/` suites covering the engine (create/encode/decode/drawImage round-trips), every component's wiring, and the full `CreateCanvas` → commands → `Draw` → `SavePNG` graph with decoded-pixel assertions
- `spec/` fbp-spec cases for the pure components
- Publish-time `noflo.json` component manifest
