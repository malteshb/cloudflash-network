# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec

@db = db =
    iface: require('dirty') '/tmp/iface.db'    


#schema to validate incoming JSON      
ifaceSchema =
    name: "interface"
    type: "object"
    additionalProperties: false
    properties:
        static: {"type":"boolean", "required":false}
        dhcp: {"type":"boolean", "required":false}
        inetaddr: {"type":"string", "required":true}
        broadcast: {"type":"string", "required":true}
        network: {"type":"string", "required":true}
        vlan: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        gateway: {"type":"string", "required":true}
        'bridge_ports': {"type":"string", "required":false}
        'bridge_fd': {"type":"number" , "required":false}
        'bridge_hello': {"type":"number", "required":false}
        'bridge_maxage': {"type":"number", "required":false}
        'bridge_stp': {"type":"string", "required":false}


            

class interfaces
    constructor:  ->
        console.log 'networklib initialized'
        ifdb = db.iface        

    getDevType: (type) ->
        res = type
        switch type
            when '1'
                res = "Ether"
            when '512'
                res = "PPP"
            when '768'
                res = "Tunnel"
            when '769'
                res = "Tunnel6"
            when '772'
                res = "lo"
            when '778'
                res = "GRE"
        return res

    list: (callback) ->
        res = []
        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            iface = {}
            result = ''
            #Added replace to trim newline
            iface.name = ifid
            result = fileops.readFileSync "/sys/class/net/#{ifid}/operstate"
            iface.upstatus = result.replace /\n/g, ""
            result = fileops.readFileSync "/sys/class/net/#{ifid}/mtu"
            iface.mtu = result.replace /\n/g, ""
            result = fileops.readFileSync "/sys/class/net/#{ifid}/address"
            iface.address = result.replace /\n/g, ""
            type = fileops.readFileSync  "/sys/class/net/#{ifid}/type"
            typenumber = type.split('\n')
            iface.devtype = @getDevType(typenumber[0])
            console.log iface
            res.push iface
        callback (res)

    getConfig: (devName) ->
        console.log 'listing device configuration'
        entry = db.iface.get  devName
        #return new Error "#{devName} does not exist" unless entry
        console.log entry
        return entry

    # Added getStats function
    getStats: (devName) ->
        stats = {}
        result = ''
        console.log 'listing device stats' 
        result = fileops.readFileSync "/sys/class/net/#{devName}/statistics/tx_bytes"
        stats.txbytes = result.replace /\n/g, ""
        result = fileops.readFileSync "/sys/class/net/#{devName}/statistics/rx_bytes".replace /\n/g, ""
        stats.rxbytes =  result.replace /\n/g, ""
        return stats


    updateConfig: ->
        console.log 'loading config on unix system'
        ifaces = fileops.readdirSync "/sys/class/net"
        config = "auto "
        for ifid in ifaces
            config += ifid
            config += " "
        config += "\n"

        console.log config
        files = fileops.readdirSync "/config/network/interfaces"
        console.log 'files present ' + files
        for file in files
            config += fileops.readFileSync "/config/network/interfaces/#{file}"
            console.log config
        #for now I do not want to mess up my ubuntu system :)    
        fileops.updateFile "/etc/network/interfaces", config
        for ifid in ifaces
            console.log 'running ifup on device ' + ifid
            exec "ifup #{ifid}"

    config: (devName, body, callback) ->
        exists = 0
        ifaces = fileops.readdirSync "/sys/class/net"        

        for ifid in ifaces
            if ifid == devName then exists = 1
        
        #return new Error "Invalid Device " + devName + " name posting!" if not exists
        #Added in try catch to fix the error
        try
            throw new Error "Invalid Device " + devName + " name posting!" unless exists            

            unless body.static or body.dhcp
                throw new Error "Invalid config posting. Must be either static or dhcp interface"
            config = "iface " + devName + " inet "
            console.log body 
            '''
            if body.static
                config += "static\n"
            else
                config += "dhcp\n"
            '''
            for key, val of body
                switch (typeof val)
                    when "number", "string"
                        config += key + ' ' + val + "\n"
                    when "boolean"
                        config += key + "\n"

            console.log 'config is ' + config
            filename = "/config/network/interfaces/#{devName}"
            fileops.createFile filename, (result) =>
                return new Error "Unable to create configuration file for device: #{devName}!" if result instanceof Error
                fileops.updateFile filename, config 
                try
                    db.iface.set devName, body, =>
                        console.log "#{devName} added to network interfaces"
                    @updateConfig()
                    callback({result:true})

                catch err
                    console.log err
                    callback(err)
        catch err
            callback(err)


    getInfo: (devName, callback) ->
        # get status, running stats, configuration for the given device
        res = {}
        result = ''        
        entry = @getConfig devName
        
        # Added try catch to fix error
        try
            throw new Error "#{devName} does not exist!" unless entry
            res.config = entry        
            res.stats = @getStats devName
            result = fileops.readFileSync "/sys/class/net/#{devName}/operstate" 
            res.operstate = result.replace /\n/g, ""
            callback (res)
        catch err
            callback(err)

    delete: (devName, callback) ->
        console.log 'deleting the devname ' + devName
        fileops.removeFile "/config/network/interfaces/#{devName}", (result) =>
            if result instanceof Error
                err = new Error "Invalid or unconfigured device posting!: #{devName}"
                callback(err)
            else
                @updateConfig()
                callback({result:true})

module.exports = interfaces
module.exports.schema = ifaceSchema

