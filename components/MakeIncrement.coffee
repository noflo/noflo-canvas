noflo = require 'noflo'

class MakeIncrement extends noflo.Component
  description: 'Make an array of numbers by increment'
  icon: 'folder-o'
  constructor: ->
    @from = null
    @to = null
    @increment = 1

    @inPorts = new noflo.InPorts
      from:
        datatype: 'number'
      to:
        datatype: 'number'
      increment:
        datatype: 'int'
        description: 'defaults to 1'

    @outPorts = new noflo.OutPorts
      range:
        datatype: 'array'

    @inPorts.from.on 'data', (data) =>
      @from = data
      @compute()

    @inPorts.to.on 'data', (data) =>
      @to = data
      @compute()

    @inPorts.increment.on 'data', (data) =>
      @increment = data
      @compute()

  compute: ->
    return unless @outPorts.range.isAttached()
    return unless @from? and @to? and @increment?
    range = []
    f = @from
    if @from <= @to
      while (f<=@to)
        range.push f
        f += @increment
    else
      while (f>=@to)
        range.push f
        f -= @increment
    @outPorts.range.send range

exports.getComponent = -> new MakeIncrement
