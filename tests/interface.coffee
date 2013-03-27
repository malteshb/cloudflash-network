interfaces = require '../lib/interfaces'
interfaces.list (res) ->
    console.log 'got response'
    console.log res

console.log interfaces.getDevType("772")
console.log interfaces.getDevType("1")
