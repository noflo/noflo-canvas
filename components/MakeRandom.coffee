noflo = require 'noflo'

class MakeRandom extends noflo.Component
  description: 'Make an array of random numbers'
  icon: 'random'
  constructor: ->
    @min = null
    @max = null
    @count = null

    @inPorts = new noflo.InPorts
      min:
        datatype: 'number'
        required: true
      max:
        datatype: 'number'
        required: true
      count:
        datatype: 'int'
        required: true
      # integer:
      #   datatype: 'boolean'
      #   required: false

    @outPorts = new noflo.OutPorts
      numbers:
        datatype: 'array'

    @inPorts.min.on 'data', (data) =>
      @min = data
      @compute()

    @inPorts.max.on 'data', (data) =>
      @max = data
      @compute()

    @inPorts.count.on 'data', (data) =>
      @count = data
      @compute()

  compute: ->
    return unless @outPorts.numbers.isAttached()
    return unless @min? and @max? and @count? and @count >= 1
    
    spread = @max - @min
    if @count is 1
      number = @min + Math.random()*spread
      @outPorts.numbers.send number
    else
      numbers = []
      for i in [0..@count-1]
        numbers[i] = @min + Math.random()*spread
      @outPorts.numbers.send numbers

    @outPorts.numbers.disconnect()

exports.getComponent = -> new MakeRandom
