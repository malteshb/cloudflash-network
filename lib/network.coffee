validate = require('json-schema').validate
interfaces = require './interfaces'
dhcp = require './dhcp'

@include = ->

    iface = new interfaces
    dh = new dhcp
    filename = "/etc/udhcpd.conf"
  
    validateIfaceSchema = ->
        console.log 'in validate schema'
        console.log @body
        result = validate @body, interfaces.schema
        console.log result
        return @next new Error "Invalid network interface configuration posting!: #{result.errors}" unless result.valid
        @next()

    # Function to validate the dhcp subnet configuration with dhcpSchema
    validateDhcpSchema = ->
        console.log 'in validateDhcpSchema'
        console.log @body
        result = validate @body, dhcp.dhcpSchema
        console.log result
        return @next new Error "Invalid dhcp configuration posting!: #{result.errors}" unless result.valid
        @next()

    # Function to validate the addresses with addrSchema
    validateAddressSchema = ->
        console.log 'in validateAddressSchema'
        console.log @body
        result = validate @body, dhcp.addrSchema
        console.log result
        return @next new Error "Invalid dhcp configuration posting!: #{result.errors}" unless result.valid
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
            console.log res
            unless res instanceof Error
                @send res
            else
                @next res

    @post '/network/dhcp/subnet', validateDhcpSchema, ->
       instance = dh.new @body
       optionvalue = '' # no option value for subnet config
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP subnet posting!#{res}"
           else
               @send instance

    @get "/network/dhcp/subnet/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Failed to fetch subnet id: #{@params.id}"

    @del '/network/dhcp/subnet/:id', ->
        console.log 'inside /network/dhcp/subnet/:id' 
        id = @params.id
        optionvalue = 'subnet'
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/router', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option router'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP router posting!#{res}"
           else
               @send instance

    @get "/network/dhcp/router/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/router/:id', ->
        id = @params.id
        optionvalue = 'option router '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/timesvr', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option timesvr'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP timesvr posting!#{res}"
           else
               @send instance

    @get "/network/dhcp/timesvr/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/timesvr/:id', ->
        id = @params.id
        optionvalue = 'option timesvr '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/namesvr', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option namesvr'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP namesvr posting!#{res}"
           else
               @send instance
               
    @get "/network/dhcp/namesvr/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/namesvr/:id', ->
        id = @params.id
        optionvalue = 'option namesvr '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/dns', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option dns'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP dns posting!#{res}"
           else
               @send instance
               
    @get "/network/dhcp/dns/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/dns/:id', ->
        id = @params.id
        optionvalue = 'option dns '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result
     
    @post '/network/dhcp/logsvr', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option logsvr'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP logsvr posting!#{res}"
           else
               @send instance
               
    @get "/network/dhcp/logsvr/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/logsvr/:id', ->
        id = @params.id
        optionvalue = 'option logsvr '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/cookiesvr', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option cookiesvr'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP cookiesvr posting!#{res}"
           else
               @send instance

    @get "/network/dhcp/cookiesvr/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/cookiesvr/:id', ->
        id = @params.id
        optionvalue = 'option cookiesvr '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/lprsvr', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option lprsvr'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP lprsvr posting!#{res}"
           else
               @send instance
               
    @get "/network/dhcp/lprsvr/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/lprsvr/:id', ->
        id = @params.id
        optionvalue = 'option lprsvr '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/ntpsrv', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option ntpsrv'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP ntpsrv posting!#{res}"
           else
               @send instance
               
    @get "/network/dhcp/ntpsrv/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/ntpsrv/:id', ->
        id = @params.id
        optionvalue = 'option ntpsrv '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @post '/network/dhcp/wins', validateAddressSchema, ->
       instance = dh.new @body
       optionvalue = 'option wins'
       dh.createConfig optionvalue, @body, filename, instance.id, (res) =>
           if res instanceof Error
               @next new Error "Invalid DHCP wins posting!#{res}"
           else
               @send instance
               
    @get "/network/dhcp/wins/:id" : ->
       dh.getConfigEntryByID @params.id, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid dhcp getting! #{res}"

    @del '/network/dhcp/wins/:id', ->
        id = @params.id
        optionvalue = 'option wins '
        result = dh.removeConfig(id, optionvalue, filename)
        @send result

    @get '/network/dhcp/router' : ->
        option="router"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/timesvr' : ->
        option="timesvr"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/namesvr' : ->
        option="namesvr"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/dns' : ->
        option="dns"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/logsvr' : ->
        option="logsvr"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/cookiesvr' : ->
        option="cookiesvr"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/lprsvr' : ->
        option="lprsvr"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/ntpsrv' : ->
        option="ntpsrv"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp/wins' : ->
        option="wins"
        dh.listConfig option, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid servers listing! #{res}"

    @get '/network/dhcp' : ->
        dh.listCompleteConfig (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid configuration listing! #{res}"            


