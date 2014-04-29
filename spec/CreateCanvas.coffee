noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  CreateCanvas = require '../components/CreateCanvas-node.coffee'
  Canvas = require 'canvas'
else
  CreateCanvas = require 'noflo-canvas/components/CreateCanvas.js'

unless noflo.isBrowser()
  describe 'node-canvas node module', ->
    can = null
    beforeEach ->
      can = new Canvas 10, 10
    describe 'before starting', ->
      it 'should be available', ->
        chai.expect(Canvas).to.be.a 'function'
      it 'should produce a valid canvas object', ->
        chai.expect(can).to.be.an 'object'
        chai.expect(can.width).to.equal 10
        chai.expect(can.height).to.equal 10

describe 'CreateCanvas component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = CreateCanvas.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.width.attach ins
    c.outPorts.canvas.attach out

  describe 'when instantiated', ->
    it 'should have two input ports', ->
      chai.expect(c.inPorts.width).to.be.an 'object'
      chai.expect(c.inPorts.height).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.canvas).to.be.an 'object'
