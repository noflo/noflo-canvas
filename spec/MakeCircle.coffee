noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  sinon = require 'sinon' unless sinon
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-canvas'

describe 'MakeCircle component (and all that inherit MakeCanvasPrimative)', ->
  c = null
  sock_center = null
  sock_radius = null
  out = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'canvas/MakeCircle', (err, instance) ->
      return done err if err
      c = instance
      sock_center = noflo.internalSocket.createSocket()
      sock_radius = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.center.attach sock_center
      c.inPorts.radius.attach sock_radius
      c.outPorts.circle.attach out
      done()
    return

  describe 'when instantiated', ->
    it 'should have two input ports', ->
      chai.expect(c.inPorts.center).to.be.an 'object'
      chai.expect(c.inPorts.radius).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.circle).to.be.an 'object'

  describe 'insuffcient input', ->
    sandbox = null
    callback = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      callback = sandbox.spy()

    afterEach ->
      sandbox.restore()

    it "shouldn't output", ->
      center =
        x: 50
        y: 50
      out.once "data", callback
      sock_center.send center
      chai.expect(callback.called).to.be.false

  describe 'single input', ->
    it 'should output one circle', (done) ->
      center =
        x: 50
        y: 50
      radius = 50
      expected = {type: 'circle', center, radius}
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.be.equal expected.type
        chai.expect(data.center).to.be.equal expected.center
        chai.expect(data.radius).to.be.equal expected.radius
        done()
      sock_center.send center
      sock_radius.send radius

  describe 'array input', ->
    it 'should output an array of circles', (done) ->
      center =
        x: 50
        y: 50
      radius = [25, 50]
      expected = [
        {type: 'circle', center, radius: radius[0]}
        {type: 'circle', center, radius: radius[1]}
      ]
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 2
        for expectedCircle, i in expected
          chai.expect(data[i].type).to.be.equal expectedCircle.type
          chai.expect(data[i].center).to.be.equal expectedCircle.center
          chai.expect(data[i].radius).to.be.equal expectedCircle.radius
        done()
      sock_center.send center
      sock_radius.send radius
