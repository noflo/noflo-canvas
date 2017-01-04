noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-canvas'

describe 'MakeGrid component', ->
  c = null
  sock_x = null
  sock_y = null
  out = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'canvas/MakeGrid', (err, instance) ->
      return done err if err
      c = instance
      sock_x = noflo.internalSocket.createSocket()
      sock_y = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.x.attach sock_x
      c.inPorts.y.attach sock_y
      c.outPorts.point.attach out
      done()

  describe 'when instantiated', ->
    it 'should have two input ports', ->
      chai.expect(c.inPorts.x).to.be.an 'object'
      chai.expect(c.inPorts.y).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.point).to.be.an 'object'

  describe 'single output', ->
    it 'should output one point', (done) ->
      x = 100
      y = 100
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'point'
        chai.expect(data.x).to.equal x
        chai.expect(data.y).to.equal y
        done()
      sock_x.send x
      sock_y.send y

  describe 'multiple output', ->
    it 'should output a grid array of points in correct order', (done) ->
      x = [0, 100]
      y = [10, 50]
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 4
        chai.expect(data[0].type).to.equal 'point'
        chai.expect(data[1].type).to.equal 'point'
        chai.expect(data[2].type).to.equal 'point'
        chai.expect(data[3].type).to.equal 'point'
        chai.expect(data[0].x).to.equal x[0]
        chai.expect(data[0].y).to.equal y[0]
        chai.expect(data[1].x).to.equal x[1]
        chai.expect(data[1].y).to.equal y[0]
        chai.expect(data[2].x).to.equal x[0]
        chai.expect(data[2].y).to.equal y[1]
        chai.expect(data[3].x).to.equal x[1]
        chai.expect(data[3].y).to.equal y[1]
        done()
      sock_x.send x
      sock_y.send y
