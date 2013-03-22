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

netmaskToMask = (netmask) ->
    octets = netmask.split('.')
    count = 0
    for octet in octets
        while(octet)
            if octet & 1
                count += 1
            octet = octet >>> 1
    return count

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
              err = new Error "Unable to create configuration file for iproute2: #{filename}!"
              return err

    listIpr2ByPolicy: (policyName,callback) ->
        res = {}
        db.iproute.forEach (key, val) ->
            if val && val.config.name == policyName
              res.id = key
              res.config = val.config
        callback(res)

    generateIpr2Config: (body,type) ->
        res = ''
        policyName = ''
        for policyKey , policyObject of body
          switch policyKey
            when "name"
              policyName = policyObject
            when 'static-routes'
              # static route object contains network, netmask, gateway and interface
              gateway = interfaceName = network = netmask = ''
              for routeList in policyObject
                for routeParam, routeValue  of routeList
                  switch (routeParam)
                    when "gateway"
                      gateway = routeValue
                    when "interface"
                      interfaceName = routeValue
                    when "network"
                      network = routeValue
                    when "netmask"
                      netmask = netmaskToMask(routeValue)
                filename = "/etc/sysconfig/network-scripts/route-#{interfaceName}"
                # should we add or delete this route entry - doing it based on type
                if type == 'add'
                  config = "#{network}/#{netmask} dev #{interfaceName} table #{policyName} \n"
                  console.log 'route config: ' + config
                  console.log 'filename main: ' + filename
				  #@writeToFile filename, config
                  res += "ip rule add from all table #{policyName}; "
                  res += "ip route add #{network}/#{netmask} via #{gateway} table #{policyName}; "
                else
                  result = @removeIpr2File filename, policyName
                  res += "ip rule del from all table #{policyName}; "
                  res += "ip route del #{network}/#{netmask} via #{gateway} table #{policyName}; "
        return res


    listByIdIpr2: (id, callback)->
        entry = db.iproute.get id
        if entry
          callback(entry)
        else
          err = new Error "Invalid id #{id}"
          callback(err)

    restart_iproute: (cmd, callback)->
        exec cmd, (error, stdout, stderror) =>
         unless error
            callback(true)
          else
            callback(error)

     priNum: (callback) ->
        arrRes = []
        result = 0
        filename = "/etc/iproute2/rt_tables"
        res =  fileops.fileExistsSync filename
        unless res instanceof Error
          Exline = fileops.readFileSync filename
          arrLines = Exline.split('\n')
          for line in arrLines
            line = line.replace /^\n/g, ""
            if line
              arrRes.push line
          str = arrRes[arrRes.length - 1]
          arrStr = str.split(" ")
          if arrStr[0]
            result = parseInt(arrStr[0])
          if result > 0
            result = result + 1
          else
            result = 1
          console.log 'result: ' +  result
          callback(result)
        else
          err = new Error "error in reading file #{filename}"
          callback err

    iprConfig: (body, id, callback) ->

        exists = 0
        cmd = 0
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

        policyName = body.name
        policyCheck = 0

        rtConfig = fileops.readFileSync "/etc/iproute2/rt_tables"
        arrConfig = rtConfig.split('\n')

        policyNameStr = " #{policyName} "
        for line in arrConfig
          unless line.search(policyNameStr) is -1
            policyCheck = 1

        @listIpr2ByPolicy policyName, (Dbres) =>
          unless Dbres instanceof Error
            console.log 'here: '+ Dbres
            if Dbres.config
              cmd = @generateIpr2Config Dbres.config, 'del'
              cmd += @generateIpr2Config body, 'add'
              console.log 'cmd: ' + cmd
            else
              console.log 'new post'
              if policyCheck == 0
                @priNum (result) =>
                  unless result instanceof Error
                    rtConfig += "#{result} #{policyName} \n"
                    fileops.updateFile "/etc/iproute2/rt_tables", rtConfig
                    cmd = @generateIpr2Config body, 'add'
                  else
                    err = new Error "Unable to fetch from db iproute"
                    callback err
              else
                err = new Error "Policy already exist in rt_tables"
                callback err

            if cmd
              cmd += "ip route flush cache"
              console.log 'cmd: ' + cmd
              try
                  @restart_iproute cmd, (result) =>
                    if result instanceof Error
                      console.log error
                      return
                  res = {}
                  res.id = id
                  res.config = body
                  if Dbres.id
                    db.iproute.rm Dbres.id
                  db.iproute.set id, res, ->
                    console.log "#{id} added to iproute2 configuration"
                    callback res
              catch err
                  console.log err
                  callback err
          else
            err = new Error "Unable to fetch from db iproute"
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
            policyName = entry.config.name
            console.log 'policyName : ' + policyName
            filenameRT = "/etc/iproute2/rt_tables"
            cmd = @generateIpr2Config entry.config, 'del'
            cmd += "ip route flush cache"
            console.log 'cmd: '+ cmd
            exec cmd, (error, stdout, stderror) =>
              unless error
                console.log "stdout: #{cmd} " + stdout
                policyNameStr = " #{policyName} "
                result = @removeIpr2File filenameRT, policyNameStr
                db.iproute.rm id
                callback(true)
              else
                err = new Error + error
                callback(err)

module.exports = iproute
module.exports.iprouteSchema = iprouteSchema

