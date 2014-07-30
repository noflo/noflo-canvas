noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeColor extends MakeCanvasPrimative
  description: 'Creates HSL or HSLA color or colors'
  icon: 'tint'
  constructor: ->
    ports =
      hue:
        datatype: 'number'
        description: 'from 0 to 360'
        required: true
      saturation:
        datatype: 'number'
        description: 'from 0 to 100'
        required: true
      lightness:
        datatype: 'number'
        description: 'from 0 to 100'
        required: true
      alpha:
        datatype: 'number'
        description: 'from 0 to 1.0'
        required: false

    super 'color', ports

  # OVERRIDE default to make strings
  compute: ->
    return unless @outPorts.color.isAttached()
    return unless @props.hue? and @props.saturation? and @props.lightness?
    color = @props
    if (@props.hue instanceof Array or @props.saturation instanceof Array or
    @props.lightness instanceof Array or @props.alpha instanceof Array)
      color = @expandToArray @props
      color = color.map @colorToString
    else
      color = @colorToString @props
    @outPorts.color.send color

  colorToString: (color) ->
    if color.alpha?
      return "hsla(#{color.hue}, #{color.saturation}%, #{color.lightness}%, #{color.alpha})"
    return "hsl(#{color.hue}, #{color.saturation}%, #{color.lightness}%)"


exports.getComponent = -> new MakeColor
