chai = require 'chai'
expect = chai.expect
should = chai.should()
iface = require '../lib/interfaces.coffee'
check = require '../lib/checkschema.coffee'
iproute = require '../lib/iproute.coffee'
validate = require('json-schema').validate

#chai.Assertion.includeStack = true


# sample date to test mocha test framework
http = require('http')

options = {port:80, host:'google.com'}
orgrequest = http.request(options)

ifacestatic = {"type":"static","address":["10.1.10.142"],"netmask":"255.255.255.0","gateway":"10.1.10.1","broadcast":"10.1.10.255","post-up":["route add -net 10.10.10.0/24 gw 10.1.10.1"]}
ifacedynamic = {"dhcp":true,"type":"dynamic"}
ifaceVlan = {"type":"static","address":"10.2.10.111","netmask":"255.255.255.0","gateway":"10.1.10.1","broadcast":"10.1.10.255"}
dhcpSchema = {"start": "192.168.0.20","end": "192.168.0.254","interface": "eth0","max_leases": 254,"remaining": "yes","auto_time": 7200,"decline_time": 3600,"conflict_time": 3600,"offer_time": 60,"min_lease": 60,"lease_file": "/var/lib/misc/udhcpd.leases","pidfile": "/var/run/udhcpd.pid","notify_file": "dumpleases","siaddr": "192.168.0.22","sname": "zorak", "boot_file": "/var/lib/misc/udhcpd.leases","option": ["subnet 192.168.0.25","timezone IST"] }

ifacestatic_err = {"type":"static","address":["10.1.10.142"],"gateway":"10.1.10.1","broadcast":"10.1.10.255","post-up":["route add -net 10.10.10.0/24 gw 10.1.10.1"]}
ifacedynamic_err = {"dhcp":true}
ifaceVlan_err = {"type":"static","address":"10.2.10.111","netmask":"255.255.255.0","gateway":"10.1.10.1"}

ipr2Static = {"name":"ASTRAL","static-routes":[{"network":"10.2.56.189","netmask":"255.255.255.0","gateway":"10.2.56.1","interface":"wan0"}]}
ipr2Static_err = {"static-routes":[{"network":"10.1.2.188","netmask":"255.255.255.0","gateway":"10.2.56.1","interface":"wan0"}]}
ipr2Static_err_data = {"name":"ASTRAL","static-routes":[{"network":"10.2.56.189","netmask":"255.255.255.0","gateway":"10.2.56.1","interface":"ethtest"}]}


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

 
  it 'validate network vlan', ->
    result = null
    body = ifaceVlan
    result = validate body, iface.staticSchema
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

  
  it 'invalid network vlan ', ->
    result = null
    body = ifaceVlan_err
    result = validate body, iface.staticSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  
  it 'Test function network config function', (done) ->
    body = result = null
    body = ifacestatic
    nwk = new iface
    params = {}
    params.id = 'eth0'   
 
    nwk.config params.id, body, '', (res) =>
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
         expect(result).to.have.property('id')
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
    nwk5.delete params.id, '', (res) =>
      setTimeout (->
       result = res
       expect(result).to.eql(true)
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
       entry.should.not.be.an('object')
       done()
    ), 50
 
  it 'delete invalid device name test', (done) ->
    result = null
    params = {}
    params.id = 'eth0test'
    nwk9 = new iface
    nwk9.delete params.id, '', (res) =>
      setTimeout (->
       result = res
       expect(result).to.not.eql(true)
       done()
      ), 50
  
   
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
  
  it 'function get Vlan Info', ->
    params = {}
    params.id = 'eth0'
    params.vid = 5
    devName = params.id + '.' + params.vid    
    nwk12 = new iface    
    result = nwk12.getInfo "#{devName}"
    expect(result).to.be.an('object')   
 
  it 'function getvlan config', ->            
    nwk13 = new iface   
    nwk13.listVLAN (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.an('object')
         done()
       ), 50 
    
  
  it 'Test function network delete vlan', (done) ->    
    params = {}
    params.id = 'eth0'
    params.vid = 5  
    nwk14 = new iface
    nwk14.delete params.id, params.vid, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.eql({result:true})
         done()
       ), 50
   
  it 'validate iproute validateIprSchema', ->
    result = null
    body = ipr2Static
    result = validate body, iproute.iprouteSchema
    expect(result).to.eql({ valid: true, errors: [] })

  it 'invalid iproute validateIprSchema', ->
    result = null
    body = ipr2Static_err
    result = validate body, iproute.iprouteSchema
    expect(result).to.not.eql({ valid: true, errors: [] })

  it 'Test function iproute listIpr2', (done) ->
    result = null
    ipr1 = new iproute

    ipr1.listIpr2 (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.a('array')
         done()
       ), 50

  it 'Test function iproute listByIdIpr2', (done) ->
    result = null
    ipr2 = new iproute
    params = {}
    params.id = '7174a87e-fec6-4a51-9eeb-6ee11d36fd93'   
 

    ipr2.listByIdIpr2 params.id, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.a('array')
         done()
       ), 50
  
  it 'Test function iproute listIpr2ByPolicy', (done) ->
    result = null
    ipr3 = new iproute
    policyName = "RDS"

    ipr3.listIpr2ByPolicy policyName, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.a('object')
         expect(result).to.have.property('id')
         expect(result).to.have.property('config')
         done()
       ), 50

  it 'Test function iproute priNum', (done) ->
    result = null
    ipr4 = new iproute

    ipr4.priNum (res) =>
      setTimeout (->
         result = res         
         expect(result).to.be.a('number')        
         done()
       ), 50

  it 'Test function iproute iprConfig', (done) ->
    result = null
    ipr5 = new iproute
    body = ipr2Static
    id = ipr5.new()
    ipr5.iprConfig body, id, (res) =>
      setTimeout (->
         result = res         
         expect(result).to.be.a('object')
         expect(result).to.have.property('id')
         expect(result).to.have.property('config')        
         done()
       ), 50

  it 'Test function iproute removeIpr2', (done) ->
    result = null
    ipr6 = new iproute
    params = {}
    params.id = '4a05976f-ca37-401b-9be7-c0fb42f1a544'
    ipr6.removeIpr2 params.id, (res) =>
      setTimeout (->
         result = res         
         expect(result).to.eql(true)             
         done()
       ), 50
  
  it 'Test function iproute listByIdIpr2 with invalid input', (done) ->
    result = null
    ipr7 = new iproute
    params = {}
    params.id = '7174a87e-fec6-4a51-9eeb-6ee11d36fd93test'  

    ipr7.listByIdIpr2 params.id, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).not.to.be.a('array')
         done()
       ), 50
  it 'Test function iproute listIpr2ByPolicy with invalid input', (done) ->
    result = null
    ipr8 = new iproute
    policyName = "test"

    ipr8.listIpr2ByPolicy policyName, (res) =>
      setTimeout (->
         result = res
         console.log "result: " + result
         expect(result).to.be.a('object')
         expect(result).not.to.have.property('id')
         expect(result).not.to.have.property('config')         
         done()
       ), 50

  it 'Test function iproute iprConfig with invalid input', (done) ->
    result = null
    ipr9 = new iproute
    body = ipr2Static_err_data
    id = ipr9.new()
    ipr9.iprConfig body, id, (res) =>
      setTimeout (->
         result = res         
         expect(result).not.to.be.a('object')                
         done()
       ), 50

   it 'Test function iproute removeIpr2 with invalid input', (done) ->
    result = null
    ipr10 = new iproute
    params = {}
    params.id = '4a05976f-ca37-401b-9be7-c0fb42f1a544test'
    ipr10.removeIpr2 params.id, (res) =>
      setTimeout (->
         result = res         
         expect(result).not.to.eql(true)             
         done()
       ), 50

