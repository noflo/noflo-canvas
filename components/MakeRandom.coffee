noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Make an array of random numbers'
  c.icon = 'random'
  c.inPorts.add 'min',
    datatype: 'number'
  c.inPorts.add 'max',
    datatype: 'number'
  c.inPorts.add 'count',
    datatype: 'int'
  c.outPorts.add 'numbers',
    datatype: 'array'
  c.process (input, output) ->
    return unless input.hasData 'min', 'max', 'count'
    [min, max, count] = input.getData 'min', 'max', 'count'
    spread = max - min
    if count is 1
      number = min + Math.random()*spread
      output.sendDone
        numbers: [number]
      return
    numbers = []
    for i in [0..count-1]
      numbers[i] = min + Math.random()*spread
    output.sendDone
      numbers: numbers
