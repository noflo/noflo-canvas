noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  path = require 'path'
  testutils = require './testutils'

p = path.resolve __dirname, '../'
console.log p
loader = new noflo.ComponentLoader p

describe 'ResizeCanvas component', ->
  c = null
  sock_height = null
  sock_width = null
  sock_canvas = null
  out = null

  beforeEach (done) ->
    @timeout 10000
    loader.load 'canvas/ResizeCanvas', (err, inst) ->
      chai.expect(err).to.be.null
      c = inst
      sock_width = noflo.internalSocket.createSocket()
      sock_height = noflo.internalSocket.createSocket()
      sock_canvas = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.on 'ready', () ->
        c.network.on 'data', (edge) ->
          # console.log edge.id, edge.data
        c.inPorts.width.attach sock_width
        c.inPorts.height.attach sock_height
        c.inPorts['in'].attach sock_canvas
        c.outPorts.out.attach out
        c.network.start done
        return
    return

  describe 'when instantiated', ->
    it 'should have 3 input ports', ->
      chai.expect(c.inPorts.height).to.be.an 'object'
      chai.expect(c.inPorts.width).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'specifying height+width', ->
    it 'should resize to specified size', (done) ->
      @timeout 5000
      input = testutils.createCanvas 400, 300
      out.once "data", (canvas) ->
        chai.expect(canvas.width).to.equal 500
        chai.expect(canvas.height).to.equal 400
        done()
      sock_width.send 500
      sock_height.send 400
      sock_canvas.send input

  describe 'specifying only height', ->
    it 'should calculate width', (done) ->
      @timeout 5000
      input = testutils.createCanvas 400, 300
      out.once "data", (canvas) ->
        chai.expect(canvas.width).to.equal 533
        chai.expect(canvas.height).to.equal 400
        done()
      sock_width.send -1
      sock_height.send 400
      sock_canvas.send input

  describe 'specifying only width', ->
    it 'should calculate height', (done) ->
      @timeout 5000
      input = testutils.createCanvas 400, 300
      out.once "data", (canvas) ->
        chai.expect(canvas.width).to.equal 500
        chai.expect(canvas.height).to.equal 375
        done()
      sock_width.send 500
      sock_height.send -1
      sock_canvas.send input

