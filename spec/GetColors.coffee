noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  fs = require 'fs'
  GetColors = require '../components/GetColors.coffee'
else
  GetColors = require 'noflo-canvas/components/GetColors.js'

getImageData = (name, callback) ->
  if noflo.isBrowser()
    id = 'http://localhost:9000/spec/data/'+name
    image = new Image()
    image.onload = ->
      callback image
    image.src = id
  else
    id = 'spec/data/'+name
    image = fs.readFile id, (err, image) ->
      callback image
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
    c.inPorts.image.attach ins
    c.outPorts.colors.attach colors
    c.outPorts.canvas.attach canvas

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.image).to.be.an 'object'
    it 'should have output ports', ->
      chai.expect(c.outPorts.colors).to.be.an 'object'
      chai.expect(c.outPorts.canvas).to.be.an 'object'

  describe 'when passed an image', ->
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
      id = getImageData input, (image) ->
        ins.beginGroup id
        ins.send image
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
      id = getImageData input, (image) ->
        ins.beginGroup id
        ins.send image
        ins.endGroup()
