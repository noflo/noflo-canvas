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
    flat = @expandToArray @props[name]
    if flat?
      @props[name].flat = flat
    @compute()

  compute: =>
    if @outPorts[@type].isAttached()
      out = @expandToArray @props
      if out
        @outPorts[@type].send out

  # If any property of object is array, expand to a collection and fill rest
  expandToArray: (props) ->
    length = 0
    for own name, prop of props
      # Short circuit with empty prop
      return null unless prop? 
      # See if any prop is an array
      if prop instanceof Array
        # Short circuit with empty array
        return null unless prop.length > 0
        if prop.flat? and length < prop.flat.length
          length = prop.flat.length
        else if length < prop.length
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
        for own name, prop of props
          if prop.flat?
            obj[name] = if prop.flat[i]? then prop.flat[i] else prop.flat[i%prop.flat.length]
          else if prop instanceof Array
            obj[name] = if prop[i]? then prop[i] else prop[i%prop.length]
          else
            obj[name] = prop
        arr.push obj
      return arr
