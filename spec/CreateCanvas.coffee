noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  Canvas = require 'canvas'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-canvas'

unless noflo.isBrowser()
  describe 'node-canvas node module', ->
    can = null
    beforeEach ->
      can = new Canvas.Canvas 10, 10
    describe 'before starting', ->
      it 'should be available', ->
        chai.expect(Canvas.Canvas).to.be.a 'function'
      it 'should produce a valid canvas object', ->
        chai.expect(can.width).to.equal 10
        chai.expect(can.height).to.equal 10

describe 'CreateCanvas component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canvas/CreateCanvas', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.width.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.canvas.attach out
  afterEach ->
    c.outPorts.canvas.detach out

  describe 'when instantiated', ->
    it 'should have two input ports', ->
      chai.expect(c.inPorts.width).to.be.an 'object'
      chai.expect(c.inPorts.height).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.canvas).to.be.an 'object'
