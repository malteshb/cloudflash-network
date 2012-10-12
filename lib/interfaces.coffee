# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec

db =
    main: require('dirty') '/tmp/iface.db'


#schema to validate incoming JSON      
ifaceSchema =
    name: "network"
    type: "object"
    additionalProperties: false
    properties:
        static   : {"type":"boolean", "required":false}
        dhcp     : {"type":"string", "required":false}
        inetaddr : {"type":"string", "required":true}
        broadcast: {"type":"string", "required":true}
        networkr : {"type":"string", "required":true}
        vlan     : {"type":"string", "required":false}
        hwaddres : {"type":"string", "required":false}
        gateway  : {"type":"string", "required":false}
        'bridge_ports' : {"type":"string", "required":false}
        'bridge_fd'    : {"type":"number" , "required":false}
        'bridge_hello' : {"type":"number", "required":false}
        'bridge_maxage': {"type":"number", "required":false}
        'bridge_stp'   : {"type":"string", "required":false}
            


class interfaces
    constructor:  ->
        console.log 'networklib initialized'
        @ifdb = db.main

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
            console.log 'getting info for ' + ifid
            iface.upstatus = fileops.readFileSync "/sys/class/net/#{ifid}/operstate"
            console.log ifid + ' status ' + iface.upstatus
            iface.mtu = fileops.readFileSync "/sys/class/net/#{ifid}/mtu"
            console.log ifid + ' mtu  ' + iface.mtu
            iface.address = fileops.readFileSync "/sys/class/net/#{ifid}/address"
            console.log ifid + ' address is ' + iface.address
            type = fileops.readFileSync  "/sys/class/net/#{ifid}/type"
            typenumber = type.split('\n')
            iface.devtype = @getDevType(typenumber[0])
            res.push iface
        callback (res)

    getConfig: ->
        console.log 'listing device configuration'

    getStats: ->
        console.log 'listing device stats'

    updateConfig: (devName) ->
        #Combine all interface configs into /etc/network/interfaces file
        #and restart the interfaces

    config: (devName, body, callback) ->
        exists = 0
        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            if ifid == devName then exists = 1
        return new Error "Invalid Device " + devName + " name posting!" unless exists
        if body.static and body.dhcp
            return new Error "Invalid config posting. Must be either static or dhcp interface"
        config = "iface " + devName + " inet "
        if body.static
            config + = "static\n"
        else
            config += "dhcp\n"

        for key, val of body
            switch (typeof val)
                when "number", "string"
                    config += key + ' ' + val + "\n"
                when "boolean"
                    config += key + "\n"

        filename = "/config/network/interfaces/#{devName}"
        fileops.createFile filename, (result) ->
            return new Error "Unable to create configuration file for device: #{devName}!" if result instanceof Error
            fileops.updateFile filename, config
            try
                @ifdb.set devName, body, ->
                    console.log "#{devName} added to network interfaces"
                @updateConfig(devName)
                callback({result:true})

            catch err
                console.log err
                callback(err)

    getInfo: (devName, callback) ->
        # get status, running stats, configuration for the given device
        console.log 'in getInfo'

    delete: (devName, callback) ->
        console.log 'deleting the devname ' + devName

    
module.exports = new interfaces
module.exports.schema = ifaceSchema
