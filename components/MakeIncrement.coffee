noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Make an array of numbers by increment'
  c.icon = 'folder-o'
  c.inPorts.add 'from',
    datatype: 'number'
  c.inPorts.add 'to',
    datatype: 'number'
  c.inPorts.add 'increment',
    datatype: 'int'
    default: 1
    control: true
  c.outPorts.add 'range',
    datatype: 'array'
  c.process (input, output) ->
    return unless input.hasData 'from', 'to'
    return if input.attached('increment').length and not input.hasData('increment')
    [from, to] = input.getData 'from', 'to'
    increment = if input.hasData('increment') then input.getData('increment') else 1
    range = []
    f = from
    if from <= to
      while (f<=to)
        range.push f
        f += increment
    else
      while (f>=to)
        range.push f
        f -= increment
    output.sendDone
      range: range
