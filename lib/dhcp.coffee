# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec
fs = require 'fs'
uuid = require 'node-uuid'


@db = db =
    dhcp:  require('dirty') '/tmp/dhcp.db'


#schema to validate incoming JSON dhcp configuration
dhcpSchema =
    name: "dhcp"
    type: "object"
    additionalProperties: false
    properties:
        start:              {"type":"string", "required":true}
        end:                {"type":"string", "required":true}
        interface:          {"type":"string", "required":false}
        max_leases:         {"type":"number", "required":false}
        remaining:          {"type":"string", "required":false}
        auto_time:          {"type":"number", "required":false}
        decline_time:       {"type":"number", "required":false}
        conflict_time:      {"type":"number", "required":false}
        offer_time:         {"type":"number", "required":false}
        min_lease:          {"type":"number", "required":false}
        lease_file:         {"type":"string", "required":false}
        pidfile:            {"type":"string", "required":false}
        notify_file:        {"type":"string", "required":false}
        siaddr:             {"type":"string", "required":false}
        sname:              {"type":"string", "required":false}
        boot_file:          {"type":"string", "required":false}
        option:
           items:           {"type":"string"}

#schema to validate incoming JSON addresses
addrSchema =
      name: "dhcp"
      type: "object"
      additionalProperties: false
      properties:
          optionparam:        {"type":"string", "required":"true"}
          address:
              items:          { type: "string" }


class dhcp
    constructor:  ->
        console.log 'dhcp initialized'
        dhcpdb = db.dhcp

    # createConfig: Function to create the config from the input JSON
    createConfig: (optionvalue, @body, callback) ->
        config = ''
        for key, val of @body.address
          switch (typeof val)
            when "string"
              config += optionvalue + ' ' + val + "\n"
        callback (config)

    # writeConfig: Function to add/modify configuration and update the dhcp db with id 
    writeConfig: (filename, config, id, body, callback) ->
        fileops.fileExists filename, (result) ->
           unless result instanceof Error
               fs.createWriteStream(filename, flags: "a").write config
           else
               fileops.createFile filename, (result) ->
                  return result if result instanceof Error

               fileops.updateFile filename, config, (result) ->
                  return result if result instanceof Error
        try
           db.dhcp.set id, body, ->
              console.log "#{id} added to dhcp service configuration"
           callback({result:true})
        catch err
           console.log err
           callback(err)

    # removeConfig: Function to remove configuration with given id
    removeConfig: (id, optionvalue, filename) ->
        entry = db.dhcp.get id
        if !entry
            return { "deleted" : "no data to delete"}
        configList = []
        if optionvalue=='subnet'
          optionvalue = ''
          for key, val of entry
            switch (typeof val)
                when "number", "string"
                   config = key + ' ' + val
                   configList.push(config)
                when "object"
                   if val instanceof Array
                        for i in val
                            config = "#{key} #{i}" if key is "option"
                            configList.push(config)
        else
          configList = entry.address
        newconfig = ''
        fileops.readFile filename, (result) ->
            throw new Error result if result instanceof Error
            for line in result.toString().split '\n'
                j = 0
                flag = 0
                while j < configList.length
                    config = optionvalue
                    config += configList[j]
                    if line==config
                       flag = 1
                       j++
                    else
                       j++
                if flag == 0
                   newconfig += line + '\n'
            try
               db.dhcp.rm id, ->
                  console.log "removed config id: #{id}"
            catch err
               return { "deleted" : "failed"}

            fileops.createFile filename, (result) ->
                return result if result instanceof Error

            fileops.updateFile filename, newconfig, (result) ->
                return result if result instanceof Error
        return { "deleted" : "success"}

    # new: Function to create a new instance of uuid
    new: (config) ->
        instance = {}
        instance.id = uuid.v4()
        instance.config = config
        return instance

    # getConfigEntryByID: Function to fetch the db entry using the given id
    getConfigEntryByID: (id, callback) ->
        entry = db.dhcp.get id
        instance = {}
        if entry
            instance.id = id
            instance.config = entry
            callback( instance )
        else
            callback ({ "id": "invalid" })


module.exports = dhcp
module.exports.dhcpSchema = dhcpSchema
module.exports.addrSchema = addrSchema
