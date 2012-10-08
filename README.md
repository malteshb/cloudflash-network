cloudflash-network
==================


*List of APIs*
=============

<table>
  <tr>
    <th>Verb</th><th>URI</th><th>Description</th>
  </tr>
  <tr>
    <td>GET</td><td>/network/interfaces</td><td>List summary of network interfaces configured</td>
  </tr>
  <tr>
    <td>POST</td><td>/network/interfaces</td><td>Create network interfaces configuration</td>
  </tr>
  <tr>
    <td>GET</td><td>/network/interfaces/:id</td><td>Describes an configured network by ID</td>
  </tr>
  <tr>
    <td>DELETE</td><td>/network/interfaces/:id</td><td>Delete an configured network by ID</td>
  </tr>
</table>



*Network API*
==============

 List Network
--------------

    Verb  URI	              Description
    GET	/network/interfaces	List summary of network interfaces configured.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.


*Response*

```

    {
       "static":
       [
           {
               "device": "eth0:0",
               "inetaddr": "192.168.8.139",
               "netmask": "255.255.255.0",
               "gateway": ""
           }
       ]
    }

```

Configure Network
------------------


    Verb	URI	              Description
    POST	/network/interfaces	Create network interfaces configuration.

**Example Request and Response**

### Request JSON

    {
	"static" : [{
 	"device" : "eth0","inetaddr": "10.1.15.1",                        
	"netmask" : "255.255.255.0",
	"broadcast" : "169.254.255.255",
	"network" : "169.254.255.255",
	"vlan" : "integer",
	"hwaddress" : "string",
	"gateway" : "string",
	"up" : {
	"add" : [{ "net" : "10.1.15.2", "netmask":"255.255.255.0",
	"gw":"string"}]
	},
	"down" : {
	"del" : [{"net":"10.1.15.3", "netmask":"255.255.255.0",
	"gw":"string"}]}
	},
	{
	"device" : "lan0","inetaddr": "10.1.15.4",                        
	"netmask" : "255.255.255.0",
	"broadcast" : "169.254.255.255",
	"network" : "169.254.255.254",
	"vlan" : "integer",
	"hwaddress" : "string",
	"gateway" : "string",
	"up" : {
	"add" : [{ "net" : "10.1.15.5", "netmask":"255.255.255.0",
	"gw":"string"},
	{ "net" : "string1", "netmask":"255.255.255.0",
	"gw1":"string"}
	]
	},
	"down" : {
	"de" : [{"net":"10.1.15.6", "netmask":"255.255.255.0",
	"gw":"string"}]}
	}]
   }


### Response JSON

    {"result":"success"}


List a Network 
--------------

    Verb	URI	                     Description
    GET	/network/interfaces/:id	Describes an configured network by name.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.


*Response*

```

    { "device" : "eth0", 
      "status" : "active",
      "txbytes" : "72013", 
      "rxbytes" : "72013"
     }

```



Delete a network
----------------

    Verb	URI	                 Description
    DELETE	/network/interfaces/:id	   Delete an configured network by name.

On Success returns 200 with JSON data

*TODO: Return appropriate error code and description in case of failure.*

**Example Request and Response**

### Request Headers

    DELETE /network/interfaces/eth0 HTTP/1.1

### Response JSON

    {"result":"success"}

