check = require './checkschema'
interfaces = require './interfaces'

@include = ->

    iface = new interfaces
  
    @post '/network/interfaces/:id', check.ifaceSchema,  ->

        iface.config @params.id, @body, "", (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid network posting! #{res}"

    @post '/network/interfaces/:id/vlan/:vid', check.ifaceSchema,  ->
        iface.config @params.id, @body, @params.vid, (res) =>
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
        res = iface.getInfo @params.id
        unless res instanceof Error
            @send res
        else
            @next res

    @get "/network/interfaces/:id/vlan" : ->
        iface.listVLAN (res) =>
            unless res instanceof Error
                @send res
            else
                @next res


    @get "/network/interfaces/:id/vlan/:vid" : ->
        devName = @params.id + '.' + @params.vid
        res = iface.getInfo "#{devName}"
        unless res instanceof Error
            @send res
        else
            @next res
    


    @del "/network/interfaces/:id" : ->
        iface.delete @params.id, '',  (res) =>
            console.log res
            unless res instanceof Error
                @send 204
            else
                @next res

    @del "/network/interfaces/:id/vlan/:vid" : ->
        iface.delete @params.id, @params.vid, (res) =>
            console.log res
            unless res instanceof Error
                @send 204
            else
                @next res


