noflo = require 'noflo'
unless noflo.isBrowser()
  testutils = require './testutils'
  chai = require 'chai' unless chai
  fs = require 'fs'
  Canvas = require 'canvas'
  SaveJPEG = require '../components/SaveJPEG-node.coffee'
else
  SaveJPEG = require 'noflo-canvas/components/SaveJPEG.js'

describe 'SaveJPEG component', ->
  c = null
  beforeEach ->
    c = SaveJPEG.getComponent()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.jpeg).to.be.an 'object'

  describe 'when passed canvas', ->
    canvas = testutils.createCanvas 200,200
    s_canvas = noflo.internalSocket.createSocket()
    so_jpeg = noflo.internalSocket.createSocket()

    it 'should output something', (done) ->
      so_jpeg.once "data", (can) ->
        chai.expect(can).to.not.be.undefined
        done()

      c.outPorts.jpeg.attach so_jpeg
      c.inPorts.canvas.attach s_canvas
      s_canvas.send canvas
