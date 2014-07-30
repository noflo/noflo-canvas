noflo = require 'noflo'

class exports.MakeCanvasPrimative extends noflo.Component

  constructor: (type, ports) ->
    @type = type
    @props = {}
    @props.type = type

    @inPorts = new noflo.InPorts ports
    @outPorts = new noflo.OutPorts()
    @outPorts[type] = new noflo.OutPort
      name: type
      datatype: 'object'
      type: "noflo-canvas/#{type}"
    # Autosend on attach
    @outPorts[type].on 'attach', @compute.bind(@)

    for own name, port of ports
      if port.addressable is true
        # Set up empty array
        @props[name] = []
        # Handle data
        @inPorts[name].on 'data', @setPropertyIndexed.bind(@, name)
      else
        # Copy defaults
        if port.value? or port.required isnt false
          @props[name] = port.value
        # Handle data
        @inPorts[name].on 'data', @setProperty.bind(@, name)
        # TODO remove prop / reindex arrays on detach


  setProperty: (name, data) -> # this is bound, so use -> not =>
    @props[name] = data
    @compute()

  setPropertyIndexed: (name, data, i) -> # this is bound, so use -> not =>
    @props[name][i] = data
    @compute()

  compute: =>
    if @outPorts[@type].isAttached()
      out = {}
      for own name, prop of @props
        # Flatten array port if needed
        if @inPorts[name]? and @inPorts[name].options.addressable
          out[name] = @expandToArray prop
        else
          out[name] = prop
      # Flatten output if needed
      out = @expandToArray out
      if out
        @outPorts[@type].send out

  # If any property of object is array, expand to a collection and fill rest
  expandToArray: (props) ->
    length = 0
    keys = Object.keys(props)
    for name in keys
      prop = props[name]
      # Short circuit with empty prop
      return null unless prop? 
      # See if any prop is an array
      if prop instanceof Array
        # Short circuit with empty array
        return null unless prop.length > 0
        if length < prop.length
          length = prop.length

    if length is 0
      # No arrays, return props as given
      return props
    if length > 0
      # At least one prop is an array, so we need to output an array
      arr = []
      for i in [0..length-1]
        if props instanceof Array
          obj = []
        else
          obj = {}
          obj.type = props.type
        keys = Object.keys(props)
        for name in keys
          prop = props[name]
        # for own name, prop of props
          if prop instanceof Array
            obj[name] = if prop[i]? then prop[i] else prop[i%prop.length]
          else
            obj[name] = prop
        arr.push obj
      return arr
