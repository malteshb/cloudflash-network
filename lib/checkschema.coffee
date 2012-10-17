validate = require('json-schema').validate
interfaces = require './interfaces'
dhcp = require './dhcp'


validateIfaceStaticSchema = (body, callback) ->
    console.log 'in validate schema'
    console.log body
    result = validate body, interfaces.staticSchema
    callback result

validateIfacedynamicSchema = (body, callback) ->
    console.log 'in validate schema'
    console.log body
    result = validate body, interfaces.dynamicSchema
    callback result

validateIfaceTunnelSchema = (body, callback) ->
    console.log 'in validate schema'
    console.log body
    result = validate body, interfaces.tunnelSchema
    callback result

  
module.exports.ifaceSchema = validateIfaceSchema = ->
    console.log 'in ifaceSchema validation'
    console.log 'params type is ' + @params.type
    switch (@params.type)
        when 'static'
            validateIfaceStaticSchema @body, (result) =>
                console.log result
                return @next new Error "Invalid network static interface configuration posting!: #{result.errors}" unless result.valid
                @next()
        when 'dynamic'
            validateIfaceDynamicSchema @body, (result) =>
                console.log result
                return @next new Error "Invalid network dynamic interface configuration posting!: #{result.errors}" unless result.valid
                @next()
        when 'tunnel'
            validateIfaceTunnelSchema @body, (result) =>
                console.log result
                return @next new Error "Invalid network tunnel interface configuration posting!: #{result.errors}" unless result.valid
                @next()
        else
            return @next new Error "Unsupported Interface type: #{@params.type}!"

module.exports.dhcpSchema = validateDhcpSchema = ->
    console.log 'in validateDhcpSchema'
    console.log @body
    result = validate @body, dhcp.dhcpSchema
    console.log result
    return @next new Error "Invalid dhcp configuration posting!: #{result.errors}" unless result.valid
    @next()

module.exports.addressSchema = validateAddressSchema = ->
    console.log 'in validateAddressSchema'
    console.log @body
    result = validate @body, dhcp.addrSchema
    console.log result
    return @next new Error "Invalid dhcp configuration posting!: #{result.errors}" unless result.valid
    @next()

