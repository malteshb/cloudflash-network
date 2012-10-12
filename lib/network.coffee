validate = require('json-schema').validate
interfaces = require './interfaces'
@include = ->

    iface = new interfaces
    filename = "/etc/network/interfaces.tmp"
  
    validateIfaceSchema = ->
        result = validate @body, interfaces..schema
        console.log result
        return @next new Error "Invalid network interface configuration posting!: #{result.errors}" unless result.valid
        @next()

    @post '/network/interfaces/:id', validateIfaceSchema,  ->
        iface.config @params.id, @body, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid network posting! #{res}"
    
    @get '/network/interfaces' : ->
        iface.list (res) =>
            unless res instanceof Error
                @send res
            else
                @next res

    @get "/network/interfaces/:id" : ->
        iface.getInfo @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next res

    @del "/network/interfaces/:id" : ->
        iface.delete @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next res



     

    
