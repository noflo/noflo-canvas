noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-canvas'

describe 'MakeRectangle component', ->
  c = null
  sock_height = null
  sock_width = null
  sock_point = null
  out = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'canvas/MakeRectangle', (err, instance) ->
      return done err if err
      c = instance
      sock_width = noflo.internalSocket.createSocket()
      sock_height = noflo.internalSocket.createSocket()
      sock_point = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.width.attach sock_width
      c.inPorts.height.attach sock_height
      c.inPorts.point.attach sock_point
      c.outPorts.rectangle.attach out
      done()
    return

  describe 'when instantiated', ->
    it 'should have two input ports', ->
      chai.expect(c.inPorts.point).to.be.an 'object'
      chai.expect(c.inPorts.height).to.be.an 'object'
      chai.expect(c.inPorts.width).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.rectangle).to.be.an 'object'

  describe 'single output', ->
    it 'should output one rectangle', (done) ->
      point = { type: 'point', x: 49, y: 51 }
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'rectangle'
        chai.expect(data.point).to.equal point
        chai.expect(data.width).to.equal 100
        chai.expect(data.height).to.equal 101
        done()
      sock_width.send 100
      sock_height.send 101
      sock_point.send point

