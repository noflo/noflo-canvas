const TAU = Math.PI * 2;

/**
 * Interprets the canvas drawing-command vocabulary on a Web Canvas 2D
 * context. Commands are plain objects with a `type` field matching one of
 * the handlers below; arrays of commands are recursed into.
 */
export class DrawCommands {
  /**
   * @param {import("./engines/types.js").EngineContext} context
   * @param {import("./engines/types.js").CanvasLike} canvas
   */
  constructor(context, canvas) {
    this.context = context;
    this.canvas = canvas;
    // Dispatch map: command types are lowercase in the 1.x vocabulary
    // (fillrect) while the handlers are camelCase (fillRect). 1.x looked
    // handlers up case-sensively, so fillrect, strokerect, and clearrect
    // commands were silently ignored; the map makes the dispatch
    // case-insensitive
    /** @type {Record<string, (command: Record<string, any>) => void>} */
    this.handlers = {};
    for (const name of Object.getOwnPropertyNames(DrawCommands.prototype)) {
      if (
        name === "constructor" ||
        name === "parse" ||
        name === "parseThing" ||
        name === "strokeItems" ||
        name === "strokePath" ||
        name === "fillItems"
      ) {
        continue;
      }
      const method = /** @type {unknown} */ (
        /** @type {Record<string, unknown>} */ (
          /** @type {unknown} */ (DrawCommands.prototype)
        )[name]
      );
      if (typeof method === "function") {
        this.handlers[name.toLowerCase()] =
          /** @type {(command: Record<string, any>) => void} */ (method);
      }
    }
  }

  /**
   * Parses and executes a command or a (nested) array of commands.
   * @param {unknown} commands
   * @param {boolean} [clearEvery]
   * @returns {void}
   */
  parse(commands, clearEvery = false) {
    if (clearEvery) {
      this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
    this.parseThing(commands);
  }

  /**
   * Recurses into arrays, dispatching typed command objects.
   * @param {unknown} thing
   * @param {(() => void) | undefined} [before]
   * @param {(() => void) | undefined} [after]
   * @returns {void}
   */
  parseThing(thing, before, after) {
    if (thing && typeof thing === "object" && "type" in thing) {
      const command = /** @type {Record<string, unknown>} */ (thing);
      const handler = this.handlers[String(command.type).toLowerCase()];
      if (typeof handler === "function") {
        if (before) {
          before();
        }
        handler.call(this, command);
        if (after) {
          after();
        }
      }
    } else if (Array.isArray(thing)) {
      for (const item of thing) {
        if (item === null || item === undefined) {
          continue;
        }
        this.parseThing(item, before, after);
      }
    }
  }

  /** @param {Record<string, any>} clearRect */
  clearRect(clearRect) {
    const { x, y } = clearRect.point;
    this.context.clearRect(x, y, clearRect.width, clearRect.height);
  }

  /** @param {Record<string, any>} data */
  strokeStyle(data) {
    this.context.strokeStyle = data.value;
  }

  /** @param {Record<string, any>} data */
  lineWidth(data) {
    this.context.lineWidth = data.value;
  }

  /** @param {Record<string, any>} data */
  fillStyle(data) {
    this.context.fillStyle = data.value;
  }

  /** @param {Record<string, any>} stroke */
  stroke(stroke) {
    if (stroke.strokestyle) {
      const oldStyle = this.context.strokeStyle;
      this.context.strokeStyle = stroke.strokestyle;
      this.strokeItems(stroke);
      this.context.strokeStyle = oldStyle;
    } else {
      this.strokeItems(stroke);
    }
  }

  /**
   * Strokes the items with the current or command-provided style.
   * @param {Record<string, any>} stroke
   * @returns {void}
   */
  strokeItems(stroke) {
    if (stroke.linewidth) {
      const oldWidth = this.context.lineWidth;
      this.context.lineWidth = stroke.linewidth;
      this.strokePath(stroke);
      this.context.lineWidth = oldWidth;
    } else {
      this.strokePath(stroke);
    }
  }

  /**
   * Strokes each thing, wrapping in begin/close path.
   * @param {Record<string, any>} stroke
   * @returns {void}
   */
  strokePath(stroke) {
    const before = () => {
      this.context.beginPath();
    };
    const after = () => {
      if (stroke.closepath) {
        this.context.closePath();
      }
      this.context.stroke();
    };
    this.parseThing(stroke.items, before, after);
  }

  /** @param {Record<string, any>} fill */
  fill(fill) {
    if (fill.fillstyle) {
      const oldStyle = this.context.fillStyle;
      this.context.fillStyle = fill.fillstyle;
      this.fillItems(fill);
      this.context.fillStyle = oldStyle;
    } else {
      this.fillItems(fill);
    }
  }

  /**
   * Fills each thing, wrapping in begin/close path.
   * @param {Record<string, any>} fill
   * @returns {void}
   */
  fillItems(fill) {
    const before = () => {
      this.context.beginPath();
    };
    const after = () => {
      this.context.closePath();
      this.context.fill();
    };
    this.parseThing(fill.items, before, after);
  }

  /** @param {Record<string, any>} curve */
  bezierCurve(curve) {
    this.context.bezierCurveTo(
      curve.control1.x,
      curve.control1.y,
      curve.control2.x,
      curve.control2.y,
      curve.end.x,
      curve.end.y,
    );
  }

  /**
   * Handles a path item: points become moveTo/lineTo in order.
   * @param {unknown} thing
   * @param {number | undefined} i
   * @returns {void}
   */
  pathItem(thing, i) {
    if (Array.isArray(thing)) {
      for (const child of thing) {
        this.pathItem(child, i);
      }
      return;
    }
    if (thing && typeof thing === "object" && "type" in thing) {
      const item = /** @type {Record<string, any>} */ (thing);
      switch (item.type) {
        case "point":
          if (i === 0) {
            this.context.moveTo(item.x, item.y);
          } else {
            this.context.lineTo(item.x, item.y);
          }
          break;
        case "beziercurve":
          this.bezierCurve(item);
          break;
        case "arc":
          this.arc(item);
          break;
        default:
          break;
      }
    }
  }

  /** @param {Record<string, any>} path */
  path(path) {
    const items = path.items;
    if (!Array.isArray(items)) {
      return;
    }
    items.forEach((/** @type {unknown} */ thing, /** @type {number} */ i) => {
      if (thing === null || thing === undefined) {
        return;
      }
      this.pathItem(thing, i);
    });
  }

  /** @param {Record<string, any>} group */
  group(group) {
    for (const thing of group.groupables) {
      if (!thing || typeof thing !== "object" || !("type" in thing)) {
        continue;
      }
      const command = /** @type {Record<string, unknown>} */ (thing);
      const handler = this.handlers[String(command.type).toLowerCase()];
      if (typeof handler === "function") {
        handler.call(this, command);
      }
    }
  }

  /**
   * Applies a transform, runs nested items, then undoes the transform.
   * @param {Record<string, any>} transform
   * @param {number | undefined} recurse
   * @returns {void}
   */
  transform(transform, recurse) {
    if (transform.translate) {
      this.context.translate(transform.translate.x, transform.translate.y);
    }
    if (transform.rotate) {
      this.context.rotate(transform.rotate);
    }
    if (transform.scaleboth) {
      // Non-zero
      this.context.scale(transform.scaleboth, transform.scaleboth);
    } else if (transform.scale?.x && transform.scale?.y) {
      // Non-zero
      this.context.scale(transform.scale.x, transform.scale.y);
    }
    this.parseThing(transform.items);
    if (recurse !== undefined && recurse > 0) {
      this.transform(transform, recurse - 1);
    }
    if (transform.scaleboth) {
      this.context.scale(1 / transform.scaleboth, 1 / transform.scaleboth);
    } else if (transform.scale?.x && transform.scale?.y) {
      this.context.scale(1 / transform.scale.x, 1 / transform.scale.y);
    }
    if (transform.rotate) {
      this.context.rotate(-transform.rotate);
    }
    if (transform.translate) {
      this.context.translate(-transform.translate.x, -transform.translate.y);
    }
  }

  /** @param {Record<string, any>} recurse */
  recurse(recurse) {
    for (const thing of recurse.recursables) {
      if (!thing) {
        continue;
      }
      if (thing.type === "transform") {
        this.transform(thing, recurse.count);
      }
    }
  }

  /** @param {Record<string, any>} rect */
  rectangle(rect) {
    const { x, y } = rect.point;
    this.context.moveTo(x, y);
    this.context.lineTo(x + rect.width, y);
    this.context.lineTo(x + rect.width, y + rect.height);
    this.context.lineTo(x, y + rect.height);
    this.context.lineTo(x, y);
  }

  /** @param {Record<string, any>} fillrect */
  fillRect(fillrect) {
    const { x, y } = fillrect.point;
    this.context.fillRect(x, y, fillrect.width, fillrect.height);
  }

  /** @param {Record<string, any>} strokerect */
  strokeRect(strokerect) {
    const { x, y } = strokerect.point;
    this.context.strokeRect(x, y, strokerect.width, strokerect.height);
  }

  /** @param {Record<string, any>} arc */
  arc(arc) {
    this.context.arc(
      arc.center.x,
      arc.center.y,
      arc.radius,
      arc.start,
      arc.end,
      arc.reverse,
    );
  }

  /** @param {Record<string, any>} circle */
  circle(circle) {
    this.context.arc(circle.center.x, circle.center.y, circle.radius, 0, TAU);
  }

  /** @param {Record<string, any>} drawimage */
  drawimage(drawimage) {
    if (!drawimage.image) {
      return;
    }
    if (drawimage.sourcerect && drawimage.destrect) {
      const d = drawimage.destrect;
      const s = drawimage.sourcerect;
      this.context.drawImage(
        drawimage.image,
        s.point.x,
        s.point.y,
        s.width,
        s.height,
        d.point.x,
        d.point.y,
        d.width,
        d.height,
      );
      return;
    }
    if (drawimage.destrect) {
      const d = drawimage.destrect;
      this.context.drawImage(
        drawimage.image,
        d.point.x,
        d.point.y,
        d.width,
        d.height,
      );
      return;
    }
    if (drawimage.destpoint) {
      const p = drawimage.destpoint;
      this.context.drawImage(drawimage.image, p.x, p.y);
      return;
    }
    // Default
    this.context.drawImage(drawimage.image, 0, 0);
  }
}
