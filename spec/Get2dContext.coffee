noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Get2dContext = require '../components/Get2dContext.coffee'
else
  Get2dContext = require 'noflo-canvas/components/Get2dContext.js'

describe 'Get2dContext component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = Get2dContext.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
