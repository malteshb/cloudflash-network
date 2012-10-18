# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec

@db = db =
    iface: require('dirty') '/tmp/iface.db'
    ifaceAlias: require('dirty') '/tmp/ifacealias.db'

staticSchema =
    name: "static"
    type: "object"
    additionalProperties: false
    properties:
        address : {"type":"string", "required":true}
        netmask: {"type":"string", "required":true}
        broadcast: {"type":"string", "required":true}
        gateway: {"type":"string", "required":true}
        pointtopoint: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        mtu: {"type":"number", "required":false}
        up: {"type":"string", "required":false}
        down: {"type":"string", "required":false}


dynamicSchema =
    name: "dynamic"
    type: "object"
    additionalProperties: false
    properties:
        hostname: {"type":"string", "required":false}
        leasehours: {"type":"string", "required":false}
        leasetime: {"type":"string", "required":false}
        vendor: {"type":"string", "required":false}
        client: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        up: {"type":"string", "required":false}
        down: {"type":"string", "required":false}


tunnelSchema =
    name: "tunnel"
    type: "object"
    additionalProperties: false
    properties:
        address: {"type":"string", "required":true}
        mode: {"type":"string", "required":true}
        endpoint: {"type":"string", "required":true}
        dstaddr: {"type":"string", "required":true}
        local: {"type":"string", "required":false}
        gateway: {"type":"string", "required":false}
        ttl: {"type":"string", "required":false}
        mtu: {"type":"number", "required":false}
        up: {"type":"string", "required":false}
        down: {"type":"string", "required":false}


            

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

    devExists: (devName) ->
        ifaces = fileops.readdirSync "/sys/class/net"
        console.log 'devExists: trying to match ' + devName + ' ifaces are '
        console.log ifaces
        exists = false
        for ifid in ifaces
            if ifid == devName
                console.log 'devname matched ' + devName
                exists = true
        return exists

    list: (callback) ->
        res = []
        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            iface = {}
            result = @getInfo  ifid
            console.log result
            res.push result

        db.ifaceAlias.forEach (key,val) ->
            result = {}
            console.log 'found key ' + key + ' value is ' + val
            result.name = key
            result.config = val
            res.push result

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
        stats.txbytes = result.replace /\n/g, "" unless result instanceof Error
        result = fileops.readFileSync "/sys/class/net/#{devName}/statistics/rx_bytes".replace /\n/g, ""
        stats.rxbytes =  result.replace /\n/g, "" unless  result instanceof Error
        return stats


    updateConfig: ->
        console.log 'loading config on unix system'
        ifaces = fileops.readdirSync "/sys/class/net"
        config = "auto lo \n"
        config += "iface lo inet loopback\n"

        console.log config
        files = fileops.readdirSync "/config/network/interfaces"
        console.log 'files present ' + files
        for file in files
            config += fileops.readFileSync "/config/network/interfaces/#{file}"
            console.log config
        fileops.updateFile "/etc/network/interfaces", config
        '''
        for ifid in ifaces
            console.log 'running ifup on device ' + ifid
            exec "ifup #{ifid}"
        '''

    config: (devName, body, type, callback) ->
        exists = 0
        skip = 0
        ifaces = fileops.readdirSync "/sys/class/net"

        devicev = devName.split('.')[0]
        device = devName.split(':')[0]
        console.log 'device is ' + device
        for ifid in ifaces
            if ifid == device then exists = 1
        
        if exists == 0
            err = new Error "Invalid Device " + devName + " name posting!" unless exists
            skip = 1
            callback err

        try unless skip == 1

            config = "iface " + devName + " inet "
            console.log 'type is ' + type
            switch type
                when "static", "dynamic", "tunnel"
                    config += "#{type}\n"
                else
                    throw new Error "Invalid interface method posting! #{type}"

            for key, val of body
                switch (typeof val)
                    when "number", "string"
                        config += "  " + key + ' ' + val + "\n"
                    when "boolean"
                        config += "  " + key + "\n"

            console.log 'config is ' + config
            filename = "/config/network/interfaces/#{devName}"
            fileops.createFile filename, (result) =>
                return new Error "Unable to create configuration file for device: #{devName}!" if result instanceof Error
                fileops.updateFile filename, config
                try
                    db.iface.set devName, body, =>
                        console.log "#{devName} added to network interfaces"
                    console.log 'device is ' + device + ' devicev is ' + devicev
                    unless device == devicev
                        db.ifaceAlias.set devName, body, =>
                            console.log "Alias #{devName} added to network interfaces"
                    @updateConfig()
                    exec "ifdown #{devName}; ifup #{devName}", (error, stdout, stderror) =>
                        console.log error

                    res = {}
                    res.name = devName
                    res.config = @getConfig devName
                    callback(res)

                catch err
                    console.log err
                    callback(err)
        catch err
            callback(err)

    # should not fail, return available data
    getInfo: (deviceName, callback) ->
        # get status, running stats, configuration for the given device
        res = {}
        result = ''
        console.log 'fetching info for device: ' + deviceName
        res.name = deviceName
        entry = @getConfig deviceName
        res.config = entry

        devName = deviceName.split(':')[0]
        if @devExists(devName)
            res.stats = @getStats devName
            console.log 'reading operstate mtu and type '
            result = fileops.readFileSync "/sys/class/net/#{devName}/operstate"
            res.operstate = result.replace /\n/g, ""
            result = fileops.readFileSync "/sys/class/net/#{devName}/mtu"
            res.mtu = result.replace /\n/g, ""
            type = fileops.readFileSync  "/sys/class/net/#{devName}/type"
            typenumber = type.split('\n')
            devtype = @getDevType(typenumber[0])
            res.devtype = devtype
        else
            res = new Error "Device does not exist! #{devName}"

        return res

    delete: (devName, callback) ->
        console.log 'deleting the devname ' + devName
        exec "ifdown #{devName}"
        fileops.fileExists "/proc/sys/net/vlan/config/#{devName}", (res) =>
            exec "vconfig rem #{devName}" unless res instanceof Error

        fileops.removeFile "/config/network/interfaces/#{devName}", (result) =>
            if result instanceof Error
                err = new Error "Invalid or unconfigured device posting!: #{devName}"
                callback(err)
            else
                @updateConfig()
                db.iface.rm devName
                callback({result:true})

module.exports = interfaces
module.exports.staticSchema = staticSchema
module.exports.dynamicSchema = dynamicSchema
module.exports.tunnelSchema = tunnelSchema

