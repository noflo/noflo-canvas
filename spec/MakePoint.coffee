noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  MakePoint = require '../components/MakePoint.coffee'
else
  MakePoint = require 'noflo-canvas/components/MakePoint.js'


describe 'MakePoint component', ->
  c = null
  sock_x = null
  sock_y = null
  out = null

  beforeEach ->
    c = MakePoint.getComponent()
    sock_x = noflo.internalSocket.createSocket()
    sock_y = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.x.attach sock_x
    c.inPorts.y.attach sock_y
    c.outPorts.point.attach out

  describe 'when instantiated', ->
    it 'should have two input ports', ->
      chai.expect(c.inPorts.x).to.be.an 'object'
      chai.expect(c.inPorts.y).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.point).to.be.an 'object'

  describe 'single output', ->
    it 'should output one point', ->
      x = 100
      y = 100
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.type).to.equal 'point'
        chai.expect(data.x).to.equal x
        chai.expect(data.y).to.equal y
      sock_x.send x
      sock_y.send y

  describe 'multiple output', ->
    it 'should output an array of points', (done) ->
      x = [0, 100]
      y = [10, 50]
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 2
        chai.expect(data[0].type).to.equal 'point'
        chai.expect(data[1].type).to.equal 'point'
        chai.expect(data[0].x).to.equal x[0]
        chai.expect(data[0].y).to.equal y[0]
        chai.expect(data[1].x).to.equal x[1]
        chai.expect(data[1].y).to.equal y[1]
        done()
      sock_x.send x
      sock_y.send y
