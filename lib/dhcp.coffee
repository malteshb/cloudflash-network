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
        @dhcpdb = db.dhcp
        @dhcpdb.on 'load', ->
            console.log 'loaded dhcp.db'
            @forEach (key,val) ->
                console.log 'found ' + key 

    # createConfig: Function to create the config from the input JSON
    createConfig: (optionvalue, @body, filename, id, callback) ->
       config = ''
       if optionvalue
        if optionvalue=="subnet"
          for key, val of @body
              switch (typeof val)
                  when "number", "string"
                     config += key + ' ' + val + "\n"
                  when "boolean"
                     config += key + "\n"
                  when "object"
                     if val instanceof Array
                         for i in val
                            config += "#{key} #{i}\n" if key is "option"
        else
          for key, val of @body.address
              switch (typeof val)
                  when "number", "string"
                     config += optionvalue + ' ' + val + "\n"
        res = @writeConfig filename, config, id, body
        callback (res)
       else
        error = new Error 'optionvalue is not valid'
        callback (error)

    # writeConfig: Function to add/modify configuration and update the dhcp db with id 
    writeConfig: (filename, config, id, body) ->
        fileops.fileExists filename, (result) ->
           unless result instanceof Error
               fs.createWriteStream(filename, flags: "a").write config
           else
               fileops.createFile filename, (result) ->
                  return new Error "Unable to create configuration file for id: #{id}!" if result instanceof Error
                  fileops.updateFile filename, config, (result) ->
                      return new Error "Unable to update configuration file for id: #{id}!" if result instanceof Error
           try
              db.dhcp.set id, body, ->
                console.log "#{id} added to dhcp service configuration"
                return ({result:true})
           catch err
              console.log err
              return err

    # removeConfig: Function to remove configuration with given id
    removeConfig: (id, optionvalue, filename) ->
        entry = db.dhcp.get id
        if !entry
            return new Error "invalid post for id: #{id}!"  

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
            return new Error "Unable to read configuration file for id: #{id}!" if result instanceof Error
            for line in result.toString().split '\n'
                j = 0
                skipflag = 0
                while j < configList.length
                    config = optionvalue
                    config += configList[j]
                    if line==config
                       skipflag = 1
                       j++
                    else
                       j++
                if skipflag == 0
                   newconfig += line + '\n'

            fileops.createFile filename, (result) ->
               return new Error "Unable to create configuration file for id: #{id}!" if result instanceof Error
               fileops.updateFile filename, newconfig, (result) ->
                  return new Error "Unable to update configuration file for id: #{id}!" if result instanceof Error
            try
               db.dhcp.rm id, ->
                  console.log "removed config id: #{id}"
            catch err
               return err

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
            error = new Error "invalid posted id : #{id}!"
            callback (error)

    # listConfig: Function to get the list of servers configured
    listConfig: (optionparam, callback) ->
        config = {}
        config.server = optionparam
        config.address = []
        @dhcpdb.forEach (key,val) ->
            if val and val.optionparam == optionparam
               j = 0
               while j < val.address.length
                    config.address.push (val.address[j])
                    j++   
        callback(config)

    # listCompleteConfig: Function to get the entire configuration
    listCompleteConfig: (callback)->
        res = {"config":[]}
        @dhcpdb.forEach (key,val) ->
            console.log 'found config ' + key
            res.config.push val
        callback(res)
 

module.exports = dhcp
module.exports.dhcpSchema = dhcpSchema
module.exports.addrSchema = addrSchema
