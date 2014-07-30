noflo = require 'noflo'

class MakeRange extends noflo.Component
  description: 'Make an array of evenly-spaced numbers'
  icon: 'folder-o'
  constructor: ->
    @from = null
    @to = null
    @count = 2

    @inPorts = new noflo.InPorts
      from:
        datatype: 'number'
        required: true
      to:
        datatype: 'number'
        required: true
      count:
        datatype: 'int'
        required: true

    @outPorts = new noflo.OutPorts
      range:
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
    if @from? and @to? and @count? and @count > 1
      range = []
      f = @from
      spread = @to - @from
      increment = spread / (@count-1)
      for i in [0..@count-1]
        range[i] = @from + increment*i
      @outPorts.range.send range
    else if @from? and @count is 1
      @outPorts.range.send @from

exports.getComponent = -> new MakeRange
