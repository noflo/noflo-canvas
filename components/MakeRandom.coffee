noflo = require 'noflo'

class MakeRandom extends noflo.Component
  description: 'Make an array of random numbers'
  icon: 'folder-o'
  constructor: ->
    @min = null
    @max = null
    @count = null

    @inPorts = new noflo.InPorts
      min:
        datatype: 'number'
      max:
        datatype: 'number'
      count:
        datatype: 'int'
      # integer:
      #   datatype: 'boolean'
      #   required: false

    @outPorts = new noflo.OutPorts
      numbers:
        datatype: 'array'

    @inPorts.from.on 'data', (data) =>
      @from = data
      @compute()

    @inPorts.to.on 'data', (data) =>
      @to = data
      @compute()

    @inPorts.count.on 'data', (data) =>
      @count = data
      @compute()

  compute: ->
    return unless @outPorts.range.isAttached()
    return unless @from? and @to? and @count? and @count >= 1
    
    spread = @max - @min
    if @count is 1
      number = @min + Math.random()*spread
      @outPorts.numbers.send number
    else
      numbers = []
      for i in [0..@count-1]
        numbers[i] = @min + Math.random()*spread
      @outPorts.numbers.send numbers

exports.getComponent = -> new MakeRandom
