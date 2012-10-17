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

ifacestatic = { "address": "192.168.8.139","netmask":"192.168.8.225","broadcast":"169.254.255.255", "gateway":"10.2.56.10","pointtopoint": "cp01","hwaddres": "82:fe:6e:12:85:41","mtu": 1500,"up": "yes","down": "no"}
ifacedynamic = { "hostname": "192.168.8.139","leasehours":"4","leasetime":"60","vendor":"10.2.56.10","client": "10.2.56.11","hwaddres": "82:fe:6e:12:85:41","up": "yes","down": "no"}
ifacetunnel = {"address": "2001:470:1f06:f41::2","mode":"P2P/server","endpoint":"209.51.161.14","dstaddr":"64","local": "97.107.134.213","gateway": "2001:470:1f06:f41::1","ttl": "64","mtu": 1500,"up": "yes","down": "no"}
dhcpSchema = {"start": "192.168.0.20","end": "192.168.0.254","interface": "eth0","max_leases": 254,"remaining": "yes","auto_time": 7200,"decline_time": 3600,"conflict_time": 3600,"offer_time": 60,"min_lease": 60,"lease_file": "/var/lib/misc/udhcpd.leases","pidfile": "/var/run/udhcpd.pid","notify_file": "dumpleases","siaddr": "192.168.0.22","sname": "zorak",  "boot_file": "/var/lib/misc/udhcpd.leases","option": ["subnet 192.168.0.25","timezone IST"] }

ifacestatic_err = { "netmask":"192.168.8.225","broadcast":"169.254.255.255", "gateway":"10.2.56.10","pointtopoint": "cp01","hwaddres": "82:fe:6e:12:85:41","mtu": 1500,"up": "yes","down": "no"}
ifacedynamic_err = { "hostname": 39,"leasehours":"4","leasetime":"60","vendor":"10.2.56.10","client": "10.2.56.11","hwaddres": "82:fe:6e:12:85:41","up": "yes","down": "no"}
ifacetunnel_err = {"address": "2001:470:1f06:f41::2","mode":"P2P/server","endpoint":"209.51.161.14","dstaddr":"64","local": "97.107.134.213","gateway": "2001:470:1f06:f41::1","ttl": 64,"mtu": 1500,"up": "yes","down": "no"}



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

    
  it 'Test function network config function', (done) ->
    body = result = null
    body = ifacestatic        
    nwk = new iface     
    params = {}
    params.id = 'eth0'
    params.type = 'static'
 
    nwk.config params.id, body, params.type, (res) =>
      setTimeout (->
         result = res 
         console.log "result: " + result   
         expect(result).to.eql({result:true})      
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
         result =  nwk2.getInfo params.id 
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
    params.type = 'static'

 
    nwk6.config params.id, body, params.type, (res) =>
      setTimeout (->
         result = res 
         console.log "result: " + result   
         expect(result).to.not.eql({result:true})      
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
  
 
 