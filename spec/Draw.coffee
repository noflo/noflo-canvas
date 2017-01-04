noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  fs = require 'fs'
  Canvas = require 'canvas'
  Draw = require '../components/Draw.coffee'
  testutils = require './testutils'
else
  Draw = require 'noflo-canvas/components/Draw.js'

describe 'Draw component', ->
  c = null
  beforeEach ->
    c = Draw.getComponent()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.canvas).to.be.an 'object'

  describe 'when passed commands', ->
    canvas = testutils.createCanvas 200,200
    s_canvas = null
    s_commands = null
    s_tick = null
    so_canvas = null
    beforeEach ->
      s_canvas = noflo.internalSocket.createSocket()
      s_commands = noflo.internalSocket.createSocket()
      s_tick = noflo.internalSocket.createSocket()
      so_canvas = noflo.internalSocket.createSocket()
      c.inPorts.canvas.attach s_canvas
      c.inPorts.commands.attach s_commands
      c.inPorts.tick.attach s_tick
      c.outPorts.canvas.attach so_canvas
    commands = [
      {
        type: 'fill'
        items: {type: 'rectangle', point: {x: 0, y: 0}, width: 100, height: 100}
        fillstyle: '#000000'
      }
      {
        type: 'fill'
        items: {type: 'rectangle', point: {x: 100, y: 0}, width: 100, height: 100}
        fillstyle: '#FFFFFF'
      }
      {
        type: 'fill'
        items: {type: 'rectangle', point: {x: 0, y: 100}, width: 100, height: 100}
        fillstyle: '#0000FF'
      }
      {
        type: 'fill'
        items: {type: 'rectangle', point: {x: 100, y: 100}, width: 100, height: 100}
        fillstyle: '#00FF00'
      }
    ]
    expectedPixels = [
      [  0,   0,   0, 255] # Black
      [255, 255, 255, 255] # White
      [  0,   0, 255, 255] # Blue
      [  0, 255,   0, 255] # Green
    ]
    it 'should draw the correct image', (done) ->
      so_canvas.once "data", (can) ->
        # Check pixels
        for command, index in commands
          context = can.getContext '2d'
          point = commands[index].items.point
          # Translate point by 10 to account for antialiasing
          pixel = context.getImageData(point.x+10, point.y+10, 1, 1).data
          expectedPixel = expectedPixels[index]
          # Check rgba values of canvas pixel
          for i in [0..3]
            chai.expect(pixel[i]).to.equal expectedPixel[i]
        done()

      s_canvas.send canvas
      s_commands.send commands
      s_tick.send()
