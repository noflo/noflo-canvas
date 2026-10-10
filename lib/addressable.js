/**
 * Returns the indexes of an addressable port's attached connections that
 * currently hold a data IP.
 *
 * Typed structurally: the NoFlo namespace does not export the ProcessInput
 * class, and `has()` accepts selector arrays that `hasData()` does not.
 *
 * @param {{ attached(port: string): unknown, has(...args: unknown[]): boolean }} input
 * @param {string} port
 * @returns {number[]}
 */
export function dataIndexes(input, port) {
  return /** @type {number[]} */ (input.attached(port)).filter((idx) =>
    input.has([
      port,
      idx,
      /** @param {{ type: string }} ip */
      (ip) => ip.type === "data",
    ]),
  );
}
