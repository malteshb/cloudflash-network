chai = require 'chai'
expect = chai.expect
should = chai.should()
iface = require '../lib/interfaces.coffee'
dhcp = require '../lib/dhcp.coffee'
check = require '../lib/checkschema.coffee'

validate = require('json-schema').validate


#chai.Assertion.includeStack = true


# sample date to test mocha test framework
http = require('http')

options = {port:80, host:'google.com'}
orgrequest = http.request(options)

ifacestatic = {"address":["192.168.8.139","192.168.8.140"],"netmask":"255.255.255.0","broadcast":"192.168.8.255","gateway":"192.168.8.254","pointtopoint":"cp01","hwaddres":"82:fe:6e:12:85:41","mtu":1500,"post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1 "]}
ifacedynamic = {"dhcp":true,"hostname":"192.168.8.139","leasehours":"4","leasetime":"60","vendor":"10.2.56.10","client":"10.2.56.11","hwaddres":"82:fe:6e:12:85:41","post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1"]}
ifacetunnel = {"address":"2001:470:1f06:f41::2","mode":"P2P/server","endpoint":"209.51.161.14","dstaddr":"64","local":"97.107.134.213","gateway":"2001:470:1f06:f41::1","ttl":"64","mtu":1500,"post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1"]}
ifaceVlan = {"address":"192.168.8.139","vlan":1,"netmask":"255.255.255.0","broadcast":"192.168.8.255","gateway":"192.168.8.254","pointtopoint":"cp01","hwaddres":"82:fe:6e:12:85:41","mtu":1500,"post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1 "]}
dhcpSchema = {"start": "192.168.0.20","end": "192.168.0.254","interface": "eth0","max_leases": 254,"remaining": "yes","auto_time": 7200,"decline_time": 3600,"conflict_time": 3600,"offer_time": 60,"min_lease": 60,"lease_file": "/var/lib/misc/udhcpd.leases","pidfile": "/var/run/udhcpd.pid","notify_file": "dumpleases","siaddr": "192.168.0.22","sname": "zorak", "boot_file": "/var/lib/misc/udhcpd.leases","option": ["subnet 192.168.0.25","timezone IST"] }

ifacestatic_err = {"address":["192.168.8.139","192.168.8.140"],"broadcast":"192.168.8.255","gateway":"192.168.8.254","pointtopoint":"cp01","hwaddres":"82:fe:6e:12:85:41","mtu":1500,"post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1 "]}
ifacedynamic_err = {"hostname":"192.168.8.139","leasehours":"4","leasetime":"60","vendor":"10.2.56.10","client":"10.2.56.11","hwaddres":"82:fe:6e:12:85:41","post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1"]}
ifacetunnel_err = {"address": "2001:470:1f06:f41::2","mode":"P2P/server","endpoint":"209.51.161.14","dstaddr":"64","local": "97.107.134.213","gateway": "2001:470:1f06:f41::1","ttl": 64,"mtu": 1500,"up": "yes","down": "no"}
ifaceVlan_err = {"address":"192.168.8.139","vlan":1,"netmask":"255.255.255.0","broadcast":"192.168.8.255","pointtopoint":"cp01","hwaddres":"82:fe:6e:12:85:41","mtu":1500,"post-up":["route add -net 10.10.10.0/24 gw 192.168.8.1 "]}

dhcpconfig = {"start": "192.168.0.20", "end": "192.168.0.254", "interface": "eth0", "max_leases": 254, "remaining": "yes", "auto_time": 7200, "decline_time": 3600, "conflict_time": 3600, "offer_time": 60, "min_lease": 60, "lease_file": "/var/lib/misc/udhcpd.leases", "pidfile": "/var/run/udhcpd.pid", "notify_file": "dumpleases", "siaddr": "192.168.0.22", "sname": "zorak", "boot_file": "/var/lib/misc/udhcpd.leases", "option": ["subnet 192.168.0.25", "timezone IST"]}

dhcpconfig_err = {"interface": "eth0", "max_leases": 254, "remaining": "yes", "auto_time": 7200, "decline_time": 3600, "conflict_time": 3600, "offer_time": 60, "min_lease": 60, "lease_file": "/var/lib/misc/udhcpd.leases", "pidfile": "/var/run/udhcpd.pid", "notify_file": "dumpleases", "siaddr": "192.168.0.22", "sname": "zorak", "boot_file": "/var/lib/misc/udhcpd.leases", "option": ["subnet 192.168.0.25", "timezone IST"]}

addressconfig = {"optionparam": "router", "address": ["192.10.0.40", "192.10.0.41"]}

addressconfig_err = {"optionparam": 1234, "address": ["192.10.0.40", "192.10.0.41"]}

describe 'Testing network endpoints functions: ', ->

  
  it 'validate network validateIfaceStaticSchema', ->
    result = null
    body = ifacestatic
    result = validate body, iface.staticSchema
    expect(result).to.eql({ valid: true, errors: [] })

  it 'validate network validateIfaceDynamicSchema', ->
    result = null
    body = ifacedynamic
    result = validate body, iface.dynamicSchema
    expect(result).to.eql({ valid: true, errors: [] })

  it 'validate network validateIfaceTunnelSchema', ->
    result = null
    body = ifacetunnel
    result = validate body, iface.tunnelSchema
    expect(result).to.eql({ valid: true, errors: [] })
  
  it 'validate network validateIfaceVlanSchema', ->
    result = null
    body = ifaceVlan
    result = validate body, iface.vlanSchema
    expect(result).to.eql({ valid: true, errors: [] })


  it 'invalid network validateIfaceStaticSchema', ->
    result = null
    body = ifacestatic_err
    result = validate body, iface.staticSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  it 'invalid network validateIfaceDynamicSchema', ->
    result = null
    body = ifacedynamic_err
    result = validate body, iface.dynamicSchema
    expect(result).to.not.eql({ valid: true, errors: [] })

  it 'invalid network validateIfaceTunnelSchema', ->
    result = null
    body = ifacetunnel_err
    result = validate body, iface.tunnelSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
 
  it 'invalid network validateIfaceVlanSchema', ->
    result = null
    body = ifaceVlan_err
    result = validate body, iface.vlanSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
    
  it 'Test function network config function', (done) ->
    body = result = null
    body = ifacestatic
    nwk = new iface
    params = {}
    params.id = 'eth0'   
 
    nwk.config params.id, body, false, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.an('object')
         done()
       ), 50
  
  it 'Test function network list function ', (done) ->
    result = null
    nwk1 = new iface

    nwk1.list (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.a('array')
         done()
       ), 50
 
  it 'Test function network getInfo function ', (done) ->
    result = null
    params = {}
    params.id = 'eth0'
    nwk2 = new iface
    setTimeout (->
         result = nwk2.getInfo params.id
         console.log "result: " + result
         expect(result).to.have.property('name')
         expect(result).to.have.property('config')
         expect(result).to.have.property('stats')
         expect(result).to.have.property('operstate')
         expect(result).to.have.property('mtu')
         expect(result).to.have.property('devtype')
         done()
    ), 50
  
  it 'Test function network getConfig function ', (done) ->
    result = entry = null
    devName = 'eth0'
    nwk3 = new iface
    setTimeout (->
       entry = nwk3.getConfig devName
       expect(entry).to.be.an('object')
       expect(entry).to.have.property('address')
       expect(entry).to.have.property('gateway')
       done()
    ), 50
  
  it 'Test function network getStats function ', (done) ->
    result = entry = null
    devName = 'eth0'
    nwk4 = new iface
    setTimeout (->
       entry = nwk4.getStats devName
       expect(entry).to.be.an('object')
       expect(entry).to.have.property('txbytes')
       expect(entry).to.have.property('rxbytes')
       done()
    ), 50
  
  it 'Test function network delete function ', (done) ->
    result = null
    params = {}
    params.id = 'eth0'
    nwk5 = new iface
    nwk5.delete params.id, (res) =>
      setTimeout (->
       result = res
       expect(result).to.eql({result:true})
       done()
      ), 50
  
  it 'config Invalid device name test', (done) ->
    body = result = null
    body = ifacestatic
    nwk6 = new iface
    params = {}
    params.id = 'eth0test'
 
    nwk6.config params.id, body, false, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         result.should.not.be.an('object')
         done()
      ), 50
    
  it 'getInfo invalid device name test', (done) ->
    result = null
    params = {}
    params.id = 'eth0test'
    nwk7 = new iface
    setTimeout (->
         result = nwk7.getInfo params.id
         console.log "result: " + result
         result.should.not.be.an('object')
         done()
    ), 50
  
  it 'getConfig invalid device name test', (done) ->
    result = entry = null
    devName = 'eth0test'
    nwk8 = new iface
    setTimeout (->
       entry = nwk8.getConfig devName
       expect(entry).to.eql(undefined)
       done()
    ), 50
  
  it 'delete invalid device name test', (done) ->
    result = null
    params = {}
    params.id = 'eth0test'
    nwk9 = new iface
    nwk9.delete params.id, (res) =>
      setTimeout (->
       result = res
       expect(result).to.not.eql({result:true})
       done()
      ), 50
  
  it 'function getType', ->
    body = null 
    body = ifacestatic
    nwk10 = new iface    
    result = nwk10.getType body
    expect(result).to.eql("static")
  
  it 'Test function network vlan config function', (done) ->
    body = result = null
    body = ifaceVlan
    nwk11 = new iface
    params = {}
    params.id = 'eth0'
    params.vid = 11
 
    nwk11.config params.id, body, params.vid, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.an('object')
         done()
       ), 50

  it 'function getVlanInfo', ->
    params = {}
    params.id = 'eth0'
    params.vid = 11
    devName = params.id + '.' + params.vid    
    nwk12 = new iface    
    result = nwk12.getVlanInfo devName
    expect(result).to.be.an('object')   
  
  it 'function getConfigVlan', ->
    params = {}
    params.id = 'eth0'           
    nwk13 = new iface    
    result = nwk13.getConfigVlan params.id
    expect(result).to.be.an('array')

  it 'Test function network deleteVlan', (done) ->    
    params = {}
    params.id = 'eth0'   
    nwk14 = new iface
    nwk14.deleteVlan params.id, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.eql({result:true})
         done()
       ), 50
  
  #dhcp API test cases
  it 'validate dhcp validateDhcpSchema', ->
    result = null
    body = dhcpconfig
    result = validate body, dhcp.dhcpSchema
    expect(result).to.eql({ valid: true, errors: [] })
 
  it 'invalid dhcp validateDhcpSchema', ->
    result = null
    body = dhcpconfig_err
    result = validate body, dhcp.dhcpSchema
    expect(result).to.not.eql({ valid: true, errors: [] })

  it 'validate dhcp validateAddressSchema', ->
    result = null
    body = addressconfig
    result = validate body, dhcp.addrSchema
    expect(result).to.eql({ valid: true, errors: [] })

  it 'invalid dhcp validateAddressSchema', ->
    result = null
    body = addressconfig_err
    result = validate body, dhcp.addrSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  it 'dhcp new function ', (done) ->
    result = null
    body = addressconfig
    dh1 = new dhcp
    setTimeout (->
       result = dh1.new body
       expect(result).to.be.an('object')
       expect(result).to.have.property('id')
       expect(result).to.have.property('config')
       done()
    ), 50

  it 'invalid body dhcp validateDhcpSchema', ->
    result = null
    body = {}
    result = validate body, dhcp.dhcpSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  it 'dhcp listConfig function ', (done) ->
    result = null
    option = "router"
    dh3 = new dhcp
    dh3.listConfig option, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result.address
         expect(result).to.have.property('server')
         expect(result).to.have.property('address')
         done()
       ), 50
  
  it 'listConfig invalid option test', (done) ->
    result = null
    option = "routertest"
    dh4 = new dhcp
    dh4.listConfig option, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result.address
         expect(result).to.have.property('server')
         expect(result).to.have.property('address').with.length(0)
         done()
      ), 50
  
  it 'dhcp getConfigEntryByID function ', (done) ->
    result = null
    params = {}
    params.id = '9325e81c-4503-4ab7-81da-3215db9d1c6a'
    dh5 = new dhcp
    dh5.getConfigEntryByID params.id, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.have.property('id')
         expect(result).to.have.property('config')
         done()
       ), 50
  
  it 'getConfigEntryByID invalid id test', (done) ->
    result = null
    params = {}
    params.id = '1234567'
    dh6 = new dhcp
    dh6.getConfigEntryByID params.id, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         result.should.not.be.an('object')
         done()
      ), 50
  
  it 'dhcp createConfig function', (done) ->
    result = instance = body = null
    body = dhcpconfig
    optionvalue = 'subnet'   
    filename = "/etc/udhcpd.tmp"
    dh7 = new dhcp
    instance = dh7.new body
    console.log "result: " + instance.id  
    dh7.createConfig optionvalue, body, filename, instance.id, (res) =>
      setTimeout (->
         result = res
         expect(result).to.not.eql({result:true})
         done()
      ), 50
  
  it 'dhcp createConfig function for addressschema', (done) ->
    result = instance = body = null
    body = addressconfig
    optionvalue = 'option router'   
    filename = "/etc/udhcpd.tmp"
    dh8 = new dhcp
    instance = dh8.new body
    console.log "result: " + instance.id  
    dh8.createConfig optionvalue, body, filename, instance.id, (res) =>
      setTimeout (->
         result = res
         expect(result).to.not.eql({result:true})
         done()
      ), 50
  
  it 'dhcp createConfig invalid', (done) ->
    result = instance = body = null
    body = addressconfig
    optionvalue = ''   
    filename = "/etc/udhcpd.tmp"
    dh9 = new dhcp
    instance = dh9.new body
    console.log "result: " + instance.id  
    dh9.createConfig optionvalue, body, filename, instance.id, (res) =>
      setTimeout (->
         result = res
         expect(result).to.not.eql({result:true})
         done()
      ), 50
  
  it 'dhcp removeConfig function', (done) ->
    result = instance = body = filename = null
    id = '0381dd68-5154-487e-a0e6-cd4bc88e6794'
    optionvalue = 'option router '   
    filename = "/etc/udhcpd.tmp"
    dh10 = new dhcp    
    setTimeout (->
         result = dh10.removeConfig id, optionvalue, filename
         expect(result).to.eql({ "deleted" : "success"})
         done()
    ), 50
  
  it 'dhcp removeConfig invalid', (done) ->
    result = instance = body = filename = null
    id = '80efc5c1-17a1-4ecc-9068-2eedd8a2f0a0test'
    optionvalue = 'option router '   
    filename = "/etc/udhcpd.tmp"
    dh10 = new dhcp    
    setTimeout (->
         result = dh10.removeConfig id, optionvalue, filename
         expect(result).to.not.eql({ "deleted" : "success"})
         done()
    ), 50
  
  it 'dhcp listCompleteConfig function', (done) ->
    result = null   
    dh11 = new dhcp  
    dh11.listCompleteConfig (res) =>  
      setTimeout (->
         result = res         
         result.should.be.an('object')
         expect(result).to.have.property('config')
         done()
      ), 50
   
        

