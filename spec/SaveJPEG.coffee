noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  fs = require 'fs'
  Canvas = require 'canvas'
  SaveJPEG = require '../components/SaveJPEG-node.coffee'
else
  SaveJPEG = require 'noflo-canvas/components/SaveJPEG.js'

createCanvas = (width, height) ->
  if noflo.isBrowser()
    canvas = document.createElement 'canvas'
    canvas.width = width
    canvas.height = height
  else
    Canvas = require 'canvas'
    canvas = new Canvas width, height
  return canvas

describe 'SaveJPEG component', ->
  c = null
  beforeEach ->
    c = SaveJPEG.getComponent()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.png).to.be.an 'object'

  describe 'when passed canvas', ->
    canvas = createCanvas 200,200
    s_canvas = noflo.internalSocket.createSocket()
    so_png = noflo.internalSocket.createSocket()

    it 'should output something', (done) ->
      so_png.once "data", (can) ->
        chai.expect(can).to.not.be.undefined
        done()

      c.outPorts.png.attach so_png
      c.inPorts.canvas.attach s_canvas
      s_canvas.send canvas
