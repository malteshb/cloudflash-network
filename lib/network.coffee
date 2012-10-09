validate = require('json-schema').validate
nwklib = require './networklib'
@include = ->

    nwk = new nwklib
    filename = "/etc/network/interfaces.tmp"
  
    validateschemaNwk = ->
        result = validate @body, nwklib.nwkschema
        console.log result
        return @next new Error "Invalid network configuration posting!: #{result.errors}" unless result.valid
        @next()

    @post '/network/interfaces', validateschemaNwk,  ->
        nwk.confignwk filename, @body, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid network posting! #{res}"
    
    @get '/network/interfaces' : ->
        nwk.getallnwk filename, (res) =>
            unless res instanceof Error
                @send res
            else
                @next res

    @get "/network/interfaces/:id" : ->        
        fStatus = "/sys/class/net/#{@params.id}/operstate"
        fTxb = "/sys/class/net/#{@params.id}/statistics/tx_bytes"
        fRxb = "/sys/class/net/#{@params.id}/statistics/rx_bytes"
        nwk.getnwk fStatus, fTxb, fRxb, @params, (res) =>
            unless res instanceof Error
                @send res
            else
                @next res

     

    