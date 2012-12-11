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
        type: {"type":"string", "required":true}
        address :
           items: {"type":"string", "required":true}
        netmask: {"type":"string", "required":true}
        broadcast: {"type":"string", "required":true}
        gateway: {"type":"string", "required":true}
        pointtopoint: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        mtu: {"type":"number", "required":false}
        up:
           items: { type: "string", "required":false }
        down:
           items: { type: "string", "required":false }
        'post-up':
           items: { type: "string", "required":false }
        'post-down':
           items: { type: "string", "required":false }
        'pre-up':
           items: { type: "string", "required":false }
        'pre-down':
           items: { type: "string", "required":false }




dynamicSchema =
    name: "dynamic"
    type: "object"
    additionalProperties: false
    properties:
        type: {"type":"string", "required":true}
        dhcp: {"type":"boolean", "required":true}
        hostname: {"type":"string", "required":false}
        leasehours: {"type":"string", "required":false}
        leasetime: {"type":"string", "required":false}
        vendor: {"type":"string", "required":false}
        client: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        up:
           items: { type: "string", "required":false }
        down:
           items: { type: "string", "required":false }
        'post-up':
           items: { type: "string", "required":false }
        'post-down':
           items: { type: "string", "required":false }
        'pre-up':
           items: { type: "string", "required":false }
        'pre-down':
           items: { type: "string", "required":false }


tunnelSchema =
    name: "tunnel"
    type: "object"
    additionalProperties: false
    properties:
        type: {"type":"string", "required":true}
        address: {"type":"string", "required":true}
        mode: {"type":"string", "required":true}
        endpoint: {"type":"string", "required":true}
        dstaddr: {"type":"string", "required":true}
        local: {"type":"string", "required":false}
        gateway: {"type":"string", "required":false}
        ttl: {"type":"string", "required":false}
        mtu: {"type":"number", "required":false}
        up:
           items: { type: "string", "required":false }
        down:
           items: { type: "string", "required":false }
        'post-up':
           items: { type: "string", "required":false }
        'post-down':
           items: { type: "string", "required":false }
        'pre-up':
           items: { type: "string", "required":false }
        'pre-down':
           items: { type: "string", "required":false }

vlanSchema =
    name: "vlan"
    type: "object"
    additionalProperties: false
    properties:
        type: {"type":"string", "required":true}
        address : {"type":"string", "required":true}
        netmask: {"type":"string", "required":true}
        broadcast: {"type":"string", "required":true}
        gateway: {"type":"string", "required":true}
        pointtopoint: {"type":"string", "required":false}
        hwaddres: {"type":"string", "required":false}
        mtu: {"type":"number", "required":false}
        up:
           items: { type: "string", "required":false }
        down:
           items: { type: "string", "required":false }
        'post-up':
           items: { type: "string", "required":false }
        'post-down':
           items: { type: "string", "required":false }
        'pre-up':
           items: { type: "string", "required":false }
        'pre-down':
           items: { type: "string", "required":false }
            

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
        #console.log 'listing device configuration'
        entry = db.iface.get  devName
        return new Error "#{devName} does not exist" unless entry
        #console.log entry
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

        #console.log config
        files = fileops.readdirSync "/config/network/interfaces"
        console.log 'files present ' + files
        for file in files
            config += fileops.readFileSync "/config/network/interfaces/#{file}"
            #console.log config
        fileops.updateFile "/etc/network/interfaces", config

    generateConfig: (type, devName, devConfig, addresses, vlanid) ->
        config = ''
        ifid = 0

        config = "auto #{devName}:1 \n"
        config += "iface #{devName}:1 inet static\n"
        config += "  " + "address 169.254.255.254\n"

        if type == "static"
            for address in addresses
              config += "auto #{devName}:#{ifid} \n"
              config += "iface #{devName}:#{ifid} inet static\n"
              config += "  " + "address #{address}\n"
              if ifid == 0
                  config += devConfig
                  ifid  = ifid + 2
              else
                  ifid = ifid + 1

        else if type == "vlan"
            config = "auto #{devName}.#{vlanid} \n"
            config += "iface #{devName}.#{vlanid} inet static \n"
            config += devConfig
            config += "  " + "vlan-raw-device #{devName} \n\n"
                              
        else
            config = "auto #{devName} \n"
            config += "iface #{devName} inet #{type}"
            console.log 'type is ' + type
            switch type
              when "tunnel"
                  config += "#{type}\n"
              when "dynamic"
                  config += "dhcp\n"
              else
                  throw new Error "Invalid interface method posting! #{type}"
            config += devConfig + "\n"
        return config

    config: (devName, body, vlanid, callback) ->
        exists = 0
        skip = 0
        type = body.type
        ifaces = fileops.readdirSync "/sys/class/net"
        addresses = []
        config = ''

        for ifid in ifaces
            if ifid == devName then exists = 1
        
        if exists == 0
            err = new Error "Invalid Device " + devName + " name posting!" unless exists
            callback err
            return

        for key, val of body
            switch (typeof val)
                when "object"
                  if val instanceof Array
                    for i in val
                      switch key
                        when "post-up", "post-down", "pre-up", "pre-down", "up", "down" 
                          config += "  " + key + ' ' + i + "\n"
                        when "address"
                          addresses.push i
                when "number", "string"
                    config += "  #{key}  #{val} \n" unless key == 'type'
                when "boolean"
                    config += "  " + key + "\n"
        config = @generateConfig type, devName, config, addresses, vlanid
        console.log 'generated config' + config
        
        if type == 'vlan'
          devName = devName + '.' + vlanid
        filename = "/config/network/interfaces/#{devName}"
        fileops.createFile filename, (result) =>
            return new Error "Unable to create configuration file for device: #{devName}!" if result instanceof Error
            fileops.updateFile filename, config
            try
                db.iface.rm devName
                db.iface.set devName, body, =>
                    console.log "#{devName} added to network interfaces"
                @updateConfig()
                # update all devices in the configuraiton

                db.iface.forEach (key,val) ->
                    console.log 'updating all devices in the configuration'
                    console.log 'operating on ' + key
                    exec "/etc/init.d/networking stop; service networking start", (error, stdout, stderror) =>
                        console.log error
                        console.log "Done bringing up network interfaces"
                
                res = {}
                res.result = true
                res.config = @getConfig devName
                callback(res)

            catch err
                console.log err
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

    delete: (devName, type,  callback) ->
        console.log 'deleting the devname ' + devName
        exec "ifdown #{devName}"
        unless type==false
            devName = "#{devName}.#{type}"
            exec "vconfig rem #{devName}"
        
        fileops.removeFile "/config/network/interfaces/#{devName}" (result) =>
            if result instanceof Error
                err = new Error "Invalid or unconfigured device posting!: #{devName}"
                callback(err)
            else
                @updateConfig()
                db.iface.rm devName
                callback()
        

module.exports = interfaces
module.exports.staticSchema = staticSchema
module.exports.dynamicSchema = dynamicSchema
module.exports.tunnelSchema = tunnelSchema
module.exports.vlanSchema = vlanSchema

