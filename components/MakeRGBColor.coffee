noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeRGBColor extends MakeCanvasPrimative
  description: 'Creates RGA or RGBA color or colors'
  icon: 'tint'
  constructor: ->
    ports =
      red:
        datatype: 'number'
        description: 'from 0 to 255'
      green:
        datatype: 'number'
        description: 'from 0 to 255'
      blue:
        datatype: 'number'
        description: 'from 0 to 255'
      alpha:
        datatype: 'number'
        description: 'from 0 to 1.0'
        required: false

    super 'color', ports

  compute: ->
    return unless @outPorts.color.isAttached()
    return unless @props.red? and @props.green? and @props.blue?
    color = @props
    if (@props.red instanceof Array or @props.green instanceof Array or
    @props.blue instanceof Array or @props.alpha instanceof Array)
      color = @expandToArray @props
      color = color.map @colorToString
    else
      color = @colorToString @props
    @outPorts.color.send color

  colorToString: (color) ->
    if color.alpha?
      return "rgba(#{color.red}, #{color.green}, "+
        "#{color.blue}, #{color.alpha})"
    else
      return "rgb(#{color.red}, #{color.green}, #{color.blue})"


exports.getComponent = -> new MakeRGBColor
