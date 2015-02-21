noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  MakePath = require '../components/MakePath.coffee'
else
  MakePath = require 'noflo-canvas/components/MakePath.js'


describe 'MakePath component', ->
  c = null
  sock_0 = null
  sock_1 = null
  out = null

  beforeEach ->
    c = MakePath.getComponent()
    sock_0 = noflo.internalSocket.createSocket()
    sock_1 = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.items.attach sock_0, 0
    c.inPorts.items.attach sock_1, 1
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
      sock_0.send input

  describe 'with two points to two addressable ports', ->
    it 'should output one path', (done) ->
      input = [
        {type:'point', x: 0, y: 0}
        {type:'point', x: 10, y: 10}
      ]
      expected = {type: 'path', items: input}
      # TODO a better way to test for the last output
      count = 0
      out.on "data", (data) ->
        console.log data
        if count is 0
          chai.expect(data).to.deep.equal {
            type: 'path'
            items: [input[0]]
          }
        if count is 1
          chai.expect(data).to.deep.equal expected
          done()
        count++
      sock_0.send input[0]
      sock_1.send input[1]
