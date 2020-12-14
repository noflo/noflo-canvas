noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
  Canvas = require 'canvas'
  testutils = require './testutils'
else
  baseDir = 'noflo-canvas'

describe 'SaveJPEG component', ->
  c = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'canvas/SaveJPEG', (err, instance) ->
      return done err if err
      c = instance
      done()
    return

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
