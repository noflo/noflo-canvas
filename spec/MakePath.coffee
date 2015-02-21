noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  MakePath = require '../components/MakePath.coffee'
else
  MakePath = require 'noflo-canvas/components/MakePath.js'


describe 'MakePath component', ->
  c = null
  sock_items = null
  out = null

  beforeEach ->
    c = MakePath.getComponent()
    sock_items = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.items.attach sock_items
    c.outPorts.path.attach out

  describe 'when instantiated', ->
    it 'should have one input ports', ->
      chai.expect(c.inPorts.items).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.path).to.be.an 'object'

  describe 'with an array of points', ->
    it 'should output one path', ->
      input = [
        {type:'point', x: 0, y: 0}
        {type:'point', x: 10, y: 10}
      ]
      expected = {type: 'path', items: input}
      out.once "data", (data) ->
        chai.expect(data).to.deep.equal expected
      sock_items.send input

  describe 'with two points to two addressable ports', ->
    it 'should output one path', ->
      input = [
        {type:'point', x: 0, y: 0}
        {type:'point', x: 10, y: 10}
      ]
      expected = {type: 'path', items: input}
      # TODO a better way to test for the last output
      count = 0
      out.on "data", (data) ->
        count++
        if count is 3
          chai.expect(data).to.deep.equal expected
      sock_items.send input[0], 0
      sock_items.send input[1], 1
