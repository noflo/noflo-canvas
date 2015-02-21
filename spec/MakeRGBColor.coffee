noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  MakeRGBColor = require '../components/MakeRGBColor.coffee'
else
  MakeRGBColor = require 'noflo-canvas/components/MakeRGBColor.js'


describe 'MakeRGBColor component', ->
  c = null
  sock_r = null
  sock_g = null
  sock_b = null
  sock_alpha = null
  out = null

  beforeEach ->
    c = MakeRGBColor.getComponent()
    sock_r = noflo.internalSocket.createSocket()
    sock_g = noflo.internalSocket.createSocket()
    sock_b = noflo.internalSocket.createSocket()
    sock_alpha = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.red.attach sock_r
    c.inPorts.green.attach sock_g
    c.inPorts.blue.attach sock_b
    c.inPorts.alpha.attach sock_alpha
    c.outPorts.color.attach out

  describe 'when instantiated', ->
    it 'should have four input ports', ->
      chai.expect(c.inPorts.red).to.be.an 'object'
      chai.expect(c.inPorts.green).to.be.an 'object'
      chai.expect(c.inPorts.blue).to.be.an 'object'
      chai.expect(c.inPorts.alpha).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.color).to.be.an 'object'

  describe 'single color output', ->
    it 'should output a single color string', ->
      out.once "data", (data) ->
        chai.expect(data).to.equal 'rgb(10, 20, 30)'
      sock_r.send 10
      sock_g.send 20
      sock_b.send 30

  describe 'multiple color output', ->
    it 'should output an array of color strings for red', ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data[0]).to.equal 'rgb(0, 20, 30)'
        chai.expect(data[1]).to.equal 'rgb(10, 20, 30)'
      sock_r.send [0, 10]
      sock_g.send 20
      sock_b.send 30
    it 'should output an array of color strings for blue', ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data[0]).to.equal 'rgb(10, 20, 40)'
        chai.expect(data[1]).to.equal 'rgb(10, 30, 40)'
      sock_r.send 10
      sock_g.send [20, 30]
      sock_b.send 40
    it 'should output an array of color strings for all', ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data[0]).to.equal 'rgba(10, 20, 30, 0.25)'
        chai.expect(data[1]).to.equal 'rgba(40, 50, 60, 0.75)'
      sock_alpha.send [0.25, 0.75]
      sock_r.send [10, 40]
      sock_g.send [20, 50]
      sock_b.send [30, 60]
