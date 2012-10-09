# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec

@db = db = 
        main: require('dirty') '/tmp/network.db'


#schema to validate incoming JSON      
nwkschema =
        name: "network"
        type: "object"
        additionalProperties: false
        properties:
          static:
            type: "array"
            items:
              type: "object"
              properties:
                 device:{"type":"string", "required":true}
                 inetaddr : {"type":"string", "required":true}
                 broadcast : {"type":"string", "required":false}
                 networkr : {"type":"string", "required":false}
                 vlan : {"type":"string", "required":false}
                 hwaddres : {"type":"string", "required":false}
                 gateway : {"type":"string", "required":false}
                 up: 
                   type: "object"
                   properties:
                        add: 
                           type: "array"
                           items:
                               type: "object"
                               properties:
                                    net:{"type":"string", "required":true}
                                    netmask:{"type":"string", "required":true}
                                    gw:{"type":"string", "required":false}

class nwklib
    constructor:  ->
        console.log 'networklib initialized'
        @dbnwk = db.main   

    loopthrow: (obj,k,devName) ->
        config = ''
        for key, val of obj
            if val instanceof Array
              for i in val
                if typeof i is "object"
                  config += "     #{k} #{key} "
                  for k,v of i
                    config += "#{k} #{v} "
              
                  config += "dev #{devName} \n"             
        
        return config

    generateNwkConfig: (obj,callback) ->
        config = ''
        devName = ''
        for key, val of obj
            switch (typeof val)
                when "object"
                    if val instanceof Array                     
                        for i in val
                            if typeof i is "object"                              
                              for k, j of i
                                if typeof j isnt "object"
                                  if k.match /device/
                                      devName = j
                                      config += "auto #{j} \n"
                                      config += "iface #{j} inet #{key} \n"
                                  else
                                     config += "     #{k} #{j} \n"                                 
                                else                                  
                                  config += @loopthrow(j,k,devName)                                                
                              config += "\n\n"
                when "number", "string"
                    config += "#{key} #{val} \n"
                when "boolean"
                    config += key + "\n"
        console.log "config: " + config
        return config
       

    writeNwkConfigDb: (body,callback) ->         
        devName = ''
        try
          for key, val of body
            switch (typeof val)
                when "object"
                    if val instanceof Array
                        for i in val
                            if typeof i is "object"                              
                              for k, j of i
                                 if typeof j isnt "object"
                                   if k.match /device/
                                      devName = j                                      
                              @dbnwk.set devName, i, ->                                 
                                 console.log "network configuration saved" 
          callback({"result": "success"})      
        catch err
          console.log  "Unable to write database dbnwk"
          callback (err)   

    confignwk: (filename, body, callback) ->
    
        fileops.createFile filename, (result) ->
            return new Error "Unable to create configuration file #{filename}!" if result instanceof Error 
             
        config = ''
        config = @generateNwkConfig(body)
        
        fileops.updateFile filename, config, (result) ->
            return new Error "Unable to update configuration file #{filename}!" if result instanceof Error     
              
        @writeNwkConfigDb body, (result) ->
            return result if result instanceof Error             
        callback({"result":"success"})

    getallnwk: (filename, callback) ->
        res = {}              
        res.static = []        
        fileops.readFile filename, (result) ->            
            throw new Error result if result instanceof Error
                       
            if result
              arrStr = result.toString().split "\n\n"
              for i in arrStr
                if i.match /static/
                  
                  arrStr1 = i.split "\n"                  
                  staticobj = { "device" : "", "inetaddr" : "", "netmask" : "", "gateway" : "" }

                  strDevice = '' 
                  strIP = ''
                  strMask = '' 
                  strGw = ''
                  for j in arrStr1 
                      j = j.replace /^\s+|\s+$/g, ""
                   
                      strpos = j.indexOf "inet"
                      if strpos > 0
                        strDevice = j.substr 0, strpos
                        strDevice = strDevice.replace /iface/g, ""
                        strDevice = strDevice.trim()
                        staticobj.device = strDevice                       
                      if j.match /^address/ 
                        strIP = j.replace /address/g, ""
                        strIP = strIP.trim()
                        staticobj.inetaddr = strIP
                      else if j.match /^netmask/ 
                        strMask = j.replace /netmask/g, ""
                        strMask = strMask.trim()
                        staticobj.netmask = strMask
                      else if j.match /^gateway/ 
                        strGw = j.replace /gateway/g, ""
                        strGw = strGw.trim()
                        staticobj.gateway = strGw 
                        
                  res.static.push staticobj                                                                 
            else
                return new Error "Unable to get all network interface info"                   
        callback(res)

    getnwk: (fStatus, fTxb,fRxb, params, callback) ->
        res = { "device" : "", "status" : "", "txbytes" : "", "rxbytes" : "" }       
        resultTx = ''
        resultRx = ''
        fileops.readFile fStatus, (result) ->
            throw new Error result if result instanceof Error
            if result
                result = result.toString().replace /\n/g, ""
                res.device = params.id
                res.status = result
                fileops.readFile fTxb, (resultTx) ->
                  if resultTx
                    resultTx = resultTx.toString().replace /\n/g, ""
                    res.txbytes = resultTx
                fileops.readFile fRxb, (resultRx) ->
                  if resultRx                    
                    resultRx = resultRx.toString().replace /\n/g, ""
                    res.rxbytes = resultRx                
                callback(res)
            else
                return new Error new Error " Invalid interface name"
    
module.exports = nwklib
module.exports.nwkschema = nwkschema
