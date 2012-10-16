chai = require 'chai'
expect = chai.expect
should = chai.should()
iface = require '../lib/interfaces.coffee'

validate = require('json-schema').validate


#chai.Assertion.includeStack = true 


# sample date to test mocha test framework
http = require('http')

options = {port:80, host:'google.com'}
orgrequest = http.request(options)

ifacestatic = {"static":  true,  "inetaddr": "192.168.8.139", "broadcast":"broadcast1", "network":"192.168.8.225", "gateway":"10.2.56.10"}

ifacestatic_err = {"static":  true,"inetaddr": "192.168.8.139", "broadcast":"broadcast1", "gateway":"10.2.56.10"}



describe 'Testing network endpoints functions: ', ->
 
  it 'validate network validateIfaceSchema', ->
    result = null
    body = ifacestatic        
    result = validate body, iface.schema
    expect(result).to.eql({ valid: true, errors: [] })  
 
  it 'invalid network validateIfaceSchema', ->
    result = null
    body = ifacestatic_err        
    result = validate body, iface.schema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  it 'Test function network config function', (done) ->
    body = result = null
    body = ifacestatic        
    nwk = new iface     
    params = {}
    params.id = 'eth0'
 
    nwk.config params.id, body, (res) =>
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
  
    nwk2.getInfo params.id, (res) =>
      setTimeout (->
         result = res 
         console.log "result: " + result          
         expect(result).to.have.property('config') 
         expect(result).to.have.property('stats')
         expect(result).to.have.property('operstate')       
         done()
       ), 50

  it 'Test function network getConfig function ', (done) ->
    result = entry = null
    devName = 'eth0'
    nwk3 = new iface 
    setTimeout (->
       entry = nwk3.getConfig devName
       expect(entry).to.be.an('object')
       expect(entry).to.have.property('inetaddr')
       expect(entry).to.have.property('network')
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
 
    nwk6.config params.id, body, (res) =>
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
  
    nwk7.getInfo params.id, (res) =>
      setTimeout (->
         result = res 
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
 
 
