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
            iface.name = ifid
            iface.upstatus = fileops.readFileSync "/sys/class/net/#{ifid}/operstate"
            iface.mtu = fileops.readFileSync "/sys/class/net/#{ifid}/mtu"
            iface.address = fileops.readFileSync "/sys/class/net/#{ifid}/address"
            type = fileops.readFileSync  "/sys/class/net/#{ifid}/type"
            typenumber = type.split('\n')
            iface.devtype = @getDevType(typenumber[0])
            console.log iface
            res.push iface
        callback (res)

    getConfig: (devName) ->
        console.log 'listing device configuration'
        entry = db.iface.get  devName
        console.log entry
        return entry

    getStats: ->
        console.log 'listing device stats'

    updateConfig: (devName) ->
        console.log 'loading config on unix system'
        #Combine all interface configs into /etc/network/interfaces file
        #and restart the interfaces.

    config: (devName, body, callback) ->
        exists = 0
        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            if ifid == devName then exists = 1
        return new Error "Invalid Device " + devName + " name posting!" unless exists
        if body.static and body.dhcp
            return new Error "Invalid config posting. Must be either static or dhcp interface"
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
                @updateConfig devName
                callback({result:true})

            catch err
                console.log err
                callback(err)

    getInfo: (devName, callback) ->
        # get status, running stats, configuration for the given device
        res = {}
        res.config = @getConfig devName
        res.stats = @getStats devName
        res.operstate = fileops.readFileSync "/sys/class/net/#{ifid}/operstate"
        callback (res)

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
