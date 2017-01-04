noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-canvas'

describe 'MakeRectangleAspectRatio component', ->
  c = null
  sockets = null
  out = null
  zeropoint = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'canvas/MakeRectangleAspectRatio', (err, instance) ->
      return done err if err
      c = instance
      zeropoint =
        type: 'point'
        x: 0
        y: 0
      sockets =
        origwidth: new noflo.internalSocket.createSocket()
        origheight: new noflo.internalSocket.createSocket()
        width: new noflo.internalSocket.createSocket()
        height: new noflo.internalSocket.createSocket()
      for name, socket of sockets
        c.inPorts[name].attach socket
      out = new noflo.internalSocket.createSocket()
      c.outPorts.rectangle.attach out
      done()

  describe 'when instantiated', ->
    it 'should have 4 input ports', ->
      chai.expect(c.inPorts.height).to.be.an 'object'
      chai.expect(c.inPorts.width).to.be.an 'object'
      chai.expect(c.inPorts.origheight).to.be.an 'object'
      chai.expect(c.inPorts.origwidth).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.rectangle).to.be.an 'object'

  describe 'specifying desired height and width', ->
    it 'should output rectangle with those values', (done) ->
      input =
        width: 400
        height: 500
        origheight: 200
        origwidth: 300
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'rectangle'
        chai.expect(data.point).to.eql zeropoint
        chai.expect(data.width).to.equal input.width
        chai.expect(data.height).to.equal input.height
        done()
      for port, value of input
        sockets[port].send value

  describe 'specifying -1 for both height and width', ->
    it 'should give original height and width', (done) ->
      input =
        width: -1
        height: -1
        origheight: 201
        origwidth: 301
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'rectangle'
        chai.expect(data.point).to.eql zeropoint
        chai.expect(data.width).to.equal input.origwidth
        chai.expect(data.height).to.equal input.origheight
        done()
      for port, value of input
        sockets[port].send value

  describe 'specifying -1 for height', ->
    it 'should calculate height from original aspect', (done) ->
      input =
        width: 400
        height: -1
        origwidth: 200
        origheight: 300
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'rectangle'
        chai.expect(data.point).to.eql zeropoint
        chai.expect(data.width).to.equal input.width
        chai.expect(data.height).to.equal 600
        done()
      for port, value of input
        sockets[port].send value

  describe 'specifying -1 for width', ->
    it 'should calculate width from original aspect', (done) ->
      input =
        width: -1
        height: 400
        origwidth: 300
        origheight: 200
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'rectangle'
        chai.expect(data.point).to.eql zeropoint
        chai.expect(data.width).to.equal 600
        chai.expect(data.height).to.equal input.height
        done()
      for port, value of input
        sockets[port].send value

