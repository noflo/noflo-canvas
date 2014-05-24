noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  fs = require 'fs'
  Canvas = require 'canvas'
  GetColors = require '../components/GetColors.coffee'
else
  GetColors = require 'noflo-canvas/components/GetColors.js'


createCanvas = (width, height) ->
  if noflo.isBrowser()
    canvas = document.createElement 'canvas'
    canvas.width = width
    canvas.height = height
  else
    Canvas = require 'canvas'
    canvas = new Canvas width, height
  return canvas

getImageData = (name, callback) ->
  if noflo.isBrowser()
    id = 'http://localhost:9000/spec/data/'+name
    image = new Image()
    image.onload = ->
      callback image
    image.src = id
  else
    id = 'spec/data/'+name
    fs.readFile id, (err, data) ->
      image = new Canvas.Image
      image.src = data
      callback image
  return id

getCanvasWithImage = (name, callback) ->
  id = getImageData name, (img) ->
    canvas = createCanvas img.width, img.height
    canvas.getContext('2d').drawImage(img, 0, 0)
    callback canvas
  return id

describe 'GetColors component', ->
  c = null
  ins = null
  colors = null
  canvas = null
  beforeEach ->
    c = GetColors.getComponent()
    ins = noflo.internalSocket.createSocket()
    colors = noflo.internalSocket.createSocket()
    canvas = noflo.internalSocket.createSocket()
    c.inPorts.canvas.attach ins
    c.outPorts.colors.attach colors
    c.outPorts.canvas.attach canvas

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have output ports', ->
      chai.expect(c.outPorts.colors).to.be.an 'object'
      chai.expect(c.outPorts.canvas).to.be.an 'object'

  describe 'when passed a canvas', ->
    input = 'colorful-octagon.png'
    expected = [
      [ 4, 251, 251 ]
      [ 251, 4,  4 ]
      [ 251,  251, 4 ]
      [  4, 4, 251 ]
      [ 251, 4, 251 ]
      [ 4, 251, 4 ]
      [ 4, 4, 4 ]
      [ 221, 221, 218 ]
      [ 52, 52, 4 ]
    ]
    it 'should extract the prominent colors', (done) ->
      id = null
      groups = []
      colors.once "begingroup", (group) ->
        groups.push group
      colors.once "data", (colors) ->
        chai.expect(colors).to.be.an 'array'
        chai.expect(colors).to.have.length expected.length
        chai.expect(colors[0]).to.be.an 'array'
        chai.expect(colors[0]).to.have.length 3
        chai.expect(colors).to.deep.equal expected
        chai.expect(groups).to.have.length 1
        chai.expect(groups[0]).to.equal id
        done()
      id = getCanvasWithImage input, (canvas) ->
        ins.beginGroup id
        ins.send canvas
        ins.endGroup()

    it 'should send canvas out', (done) ->
      id = null
      groups = []
      canvas.once "begingroup", (group) ->
        groups.push group
      canvas.once "data", (canvas) ->
        chai.expect(canvas).to.be.an 'object'
        chai.expect(groups).to.have.length 1
        chai.expect(groups[0]).to.equal id
        done()
      id = getCanvasWithImage input, (canvas) ->
        ins.beginGroup id
        ins.send canvas
        ins.endGroup()
