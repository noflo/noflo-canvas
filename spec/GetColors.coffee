noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetColors = require '../components/GetColors.coffee'
else
  GetColors = require 'noflo-canvas/components/GetColors.js'

describe 'GetColors component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = GetColors.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.image.attach ins
    c.outPorts.colors.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.image).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.colors).to.be.an 'object'
