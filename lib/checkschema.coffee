validate = require('json-schema').validate
interfaces = require './interfaces'


validateIfaceStaticSchema = (body, callback) ->
    console.log 'in validate schema'
    console.log body
    result = validate body, interfaces.staticSchema
    callback result

validateIfaceDynamicSchema = (body, callback) ->
    console.log 'in validate schema'
    console.log body
    result = validate body, interfaces.dynamicSchema
    callback result

  
module.exports.ifaceSchema = validateIfaceSchema = ->
    console.log 'in ifaceSchema validation ' + @body.type
    console.log @body
    
    switch (@body.type)
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
        else
            return @next new Error "Unsupported Interface type: #{@params.type}!"

