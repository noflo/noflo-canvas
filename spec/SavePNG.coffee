noflo = require 'noflo'
unless noflo.isBrowser()
  testutils = require './testutils'
  chai = require 'chai' unless chai
  fs = require 'fs'
  Canvas = require 'canvas'
  SavePNG = require '../components/SavePNG-node.coffee'
else
  SavePNG = require 'noflo-canvas/components/SavePNG.js'



describe 'SavePNG component', ->
  c = null
  beforeEach ->
    c = SavePNG.getComponent()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.png).to.be.an 'object'

  describe 'when passed canvas', ->
    canvas = testutils.createCanvas 200,200
    s_canvas = noflo.internalSocket.createSocket()
    so_png = noflo.internalSocket.createSocket()

    it 'should output something', (done) ->
      so_png.once "data", (can) ->
        chai.expect(can).to.not.be.undefined
        done()

      c.outPorts.png.attach so_png
      c.inPorts.canvas.attach s_canvas
      s_canvas.send canvas
