noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-canvas'

describe 'MakeColor component', ->
  c = null
  sock_hue = null
  sock_saturation = null
  sock_lightness = null
  sock_alpha = null
  out = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'canvas/MakeColor', (err, instance) ->
      return done err if err
      c = instance
      sock_hue = noflo.internalSocket.createSocket()
      sock_saturation = noflo.internalSocket.createSocket()
      sock_lightness = noflo.internalSocket.createSocket()
      sock_alpha = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.hue.attach sock_hue
      c.inPorts.saturation.attach sock_saturation
      c.inPorts.lightness.attach sock_lightness
      c.inPorts.alpha.attach sock_alpha
      c.outPorts.color.attach out
      done()
    return

  describe 'when instantiated', ->
    it 'should have four input ports', ->
      chai.expect(c.inPorts.hue).to.be.an 'object'
      chai.expect(c.inPorts.saturation).to.be.an 'object'
      chai.expect(c.inPorts.lightness).to.be.an 'object'
      chai.expect(c.inPorts.alpha).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.color).to.be.an 'object'

  describe 'single color output', ->
    it 'should output a color string', (done) ->
      out.once "data", (data) ->
        chai.expect(data).to.equal 'hsl(0, 100%, 50%)'
        done()
      sock_hue.send 0
      sock_saturation.send 100
      sock_lightness.send 50

  describe 'multiple color output', ->
    it 'should output an array of color strings for hue', (done) ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data[0]).to.equal 'hsl(0, 100%, 50%)'
        chai.expect(data[1]).to.equal 'hsl(1, 100%, 50%)'
        done()
      sock_hue.send [0, 1]
      sock_saturation.send 100
      sock_lightness.send 50
    it 'should output an array of color strings for saturation', (done) ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data[0]).to.equal 'hsl(0, 50%, 50%)'
        chai.expect(data[1]).to.equal 'hsl(0, 100%, 50%)'
        done()
      sock_hue.send 0
      sock_saturation.send [50, 100]
      sock_lightness.send 50
    it 'should output an array of color strings for all', (done) ->
      out.once "data", (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data[0]).to.equal 'hsla(0, 50%, 25%, 0.25)'
        chai.expect(data[1]).to.equal 'hsla(1, 100%, 75%, 0.75)'
        done()
      sock_alpha.send [0.25, 0.75]
      sock_hue.send [0, 1]
      sock_saturation.send [50, 100]
      sock_lightness.send [25, 75]
