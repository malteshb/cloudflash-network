# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec
uuid = require 'node-uuid'
fs = require("fs")

@db = db =    
    iproute: require('dirty') '/tmp/iproute.db'

iprouteSchema =
    name: "iproute"
    type: "object"
    additionalProperties: false
    properties:
        name: {"type":"string", "required":true}
        'static-routes':
           type: "array"
           items: 
              type: "object"
              properties:
                 network:{"type":"string", "required":true}
                 netmask:{"type":"string", "required":true}
                 gateway:{"type":"string", "required":true}
                 interface:{"type":"string", "required":true}            

class iproute
    constructor:  ->
        console.log 'iproute initialized'
        ipdb = db.iproute
       
    new: ->
        id = uuid.v4()
        return id
    listIpr2: (callback) ->
        res = []
        db.iproute.forEach (key, val) ->
            res.push val if val
        callback(res)
   
    writeToFile : (filename, config, callback) ->
        res =  fileops.fileExistsSync filename
        unless res instanceof Error
          Exconfig = fileops.readFileSync filename
          newConfig = Exconfig + '\n' 
          newConfig += config
          fileops.updateFile filename, newConfig
          return
        else
          fileops.createFile filename, (result) =>
            unless result instanceof Error              
              fileops.updateFile filename, config
              return
            else
              err = new Error "Unable to create configuration file for iproute2: #{ipr2Iface}!" 
              return err
    
    generateIpr2Config: (body,type) ->
        res = ''        
        policyName = ''
        for key, val of body
          switch key
            when "name"
              policyName = val
            when 'static-routes'
              switch (typeof val)                
                when "object"
                  if val instanceof Array
                    gateway = ''
                    ipr2Iface = ''
                    network = ''
                    for i in val
                      if typeof i is "object"
                        for k, j of i                                                    
                          switch (k)
                            when "gateway"
                              gateway = j
                            when "interface"
                              ipr2Iface = j
                            when "network"
                              network = j                                                    
                        config = "#{network}/24 dev #{ipr2Iface} src #{network} table #{policyName} \n"
                        config += "default via #{gateway} dev #{ipr2Iface} table #{policyName} \n"
                        console.log 'route config: ' + config
                        filename = "/etc/sysconfig/network-scripts/route-#{ipr2Iface}"
                        console.log 'filename main: ' + filename
                        @writeToFile filename, config                        
                        res += "ip route add default via #{gateway} dev #{ipr2Iface} table #{policyName}; "                             
                        res += "ip rule add from #{network} table #{policyName}; "            
                                                      
        return res

   
    listByIdIpr2: (id, callback)->
        entry = db.iproute.get id
        if entry
          callback(entry)
        else
          err = new Error "Invalid id #{id}"
          callback(err)

    checkIpr2: (callback) ->
        res = []
        db.iproute.forEach (key, val) ->
            console.log 'val:' + val.config.name
            res.push val if val
        callback(res)

    iprConfig: (body, id, callback) ->
        exists = 0
        ifaceArr = []        
        ifaceArr = @getIpr2Info body, "interface"         

        ifaces = fileops.readdirSync "/sys/class/net"
        for ifid in ifaces
            ifaceArr.map (item, i) ->                                         
              if ifid == item then exists = exists + 1
       
        if exists < ifaceArr.length
            err = new Error "Invalid interface name posting!"
            callback err
            return      
        
        ruleTable = " #{body.name} "      
        policyCheck = 0             
            
        rtConfig = fileops.readFileSync "/etc/iproute2/rt_tables"
        arrConfig = rtConfig.split('\n')
             
        for line in arrConfig             
          unless line.search(ruleTable) is -1
            policyCheck = 1        
        
        #console.log 'rtConfig: '+ rtConfig
        if policyCheck == 0
          @listIpr2 (result) =>
            unless result instanceof Error               
                arrIPlen = result.length + 1
                ruleTable = ruleTable.replace /^\s+/g, ""               
                rtConfig += "#{arrIPlen} #{ruleTable} \n"
                fileops.updateFile "/etc/iproute2/rt_tables", rtConfig

                cmd = @generateIpr2Config body
                cmd += "ip route flush cache"
                console.log 'cmd: ' + cmd                
                exec cmd, (error, stdout, stderror) =>                    
                    unless error
                      console.log "stdout: #{cmd} " + stdout                      
                      try
                        res = {}
                        res.id = id
                        res.config = body
                        db.iproute.set id, res, ->
                          console.log "#{id} added to iproute2 configuration"
                          callback res
                      catch err
                        console.log err
                        callback err
                    else
                      err = new Error + error
                      callback err                 
            else
              err = new Error "Unable to fetch from db iproute"
              callback err
        else
          err = new Error "Policy already exist in rt_tables"
          callback err
        

    removeIpr2File: (filename, policyName) ->
        rtConfig = fileops.readFileSync filename
        unless rtConfig instanceof Error          
          arrConfig = rtConfig.split('\n')
          newConfig = ''   
          for line in arrConfig
            line = line.replace /^\n\s+/g, ""                       
            unless line.search(policyName) isnt -1
              newConfig += line + "\n"
          console.log 'newConfig: ' + newConfig
          fileops.updateFile filename, newConfig
          return
        else
          err = new Error + rtConfig
          return err

    getIpr2Info: (obj, data) ->
        policyIface = []
        for key, val of obj
          switch key                
            when 'static-routes'
              if val instanceof Array
                for i in val
                  if typeof i is "object"
                    for k, j of i                         
                      policyIface.push j if k == data
       
        return policyIface
   
    removeIpr2: (id, callback) ->
        entry = db.iproute.get id
        unless entry
            err = new Error "No such iproute configuration!"
            callback err
        else
            policyIface = @getIpr2Info entry.config, "interface" 
            policyNwk = @getIpr2Info entry.config, "network"                       
            policyName = " #{entry.config.name} "
            console.log 'policyName : ' + policyName   
            filenameRT = "/etc/iproute2/rt_tables"           
            
            lenIface = policyIface.length
            lennwk = policyNwk.length

            result = ''
            res = ''  
            cmd = ''          
            if lenIface > 0 && lennwk > 0
              console.log 'len: ' + lenIface  + lennwk 
              for i in policyIface
                console.log 'i: ' + i
                filename = "/etc/sysconfig/network-scripts/route-#{i}"
                result = @removeIpr2File filename, policyName
                res = result if result instanceof Error    
              
              for j in policyNwk
                console.log 'j: ' + j
                cmd += "ip rule del from #{j} table #{policyName}; "
 
              cmd += "ip route flush cache"
              console.log 'cmd: '+ cmd 
              exec cmd, (error, stdout, stderror) =>                    
                unless error
                  console.log "stdout: #{cmd} " + stdout
                  result = @removeIpr2File filenameRT, policyName
                  db.iproute.rm id
                  callback(true)
                else
                  err = new Error + error
                  callback(err)                       
                
            else
              err = new Error "Invalid iproute posting #{id}"
              callback(err)  
                
               

module.exports = iproute
module.exports.iprouteSchema = iprouteSchema

