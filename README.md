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
  <tr>     
    <td>POST</td><td>/network/dhcp/subnet</td><td>Update subnet details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/subnet/:id</td><td>Describe subnet details for by id</td>  
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/subnet/:id</td><td>Delete subnet details from DHCP by id</td>  
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/router</td><td>Update router details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/router/:id</td><td>Describe router details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/router/:id</td><td>Delete router details from DHCP by id</td>
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/timesvr</td><td>Update time server details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/timesvr/:id</td><td>Describe time server details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/timesvr/:id</td><td>Delete time server details from DHCP by id</td>
  </tr>  
  <tr>
      <td>POST</td><td>/network/dhcp/namesvr</td><td>Update name server details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/namesvr/:id</td><td>Desribe name server details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/namesvr/:id</td><td>Delete name server details from DHCP by id</td>
  </tr>
  
  <tr>
      <td>POST</td><td>/network/dhcp/dns</td><td>Update dns details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/dns/:id</td><td>Describe dns details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/dns/:id</td><td>Delete dns details from DHCP by id</td>
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/logsvr</td><td>Update log server details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/logsvr/:id</td><td>Describe log server details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/logsvr/:id</td><td>Delete log server details from DHCP by id</td>
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/cookiesvr</td><td>Update cookie server details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/cookiesvr/:id</td><td>Describe cookie server details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/cookiesvr/:id</td><td>Delete cookie server details from DHCP by id</td>
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/lprsvr</td><td>Update lprsvr details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/lprsvr/:id</td><td>Describe lpr server details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/lprsvr/:id</td><td>Delete lpr server details from DHCP by id</td>
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/ntpsrv</td><td>Update NTP server details for DHCP in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/ntpsrv/:id</td><td>Describe ntp server details for DHCP by id</td>
  </tr>
  <tr>
      <td>DELETE</td><td>/network/dhcp/ntpsrv/:id</td><td>Delete ntp server details from DHCP by id</td>
  </tr>
  <tr>
      <td>POST</td><td>/network/dhcp/wins</td><td>Update the DHCP configuration with WINS details in VCG</td>
  </tr>
  <tr>
      <td>GET</td><td>/network/dhcp/wins/:id</td><td>Describe wins server details for DHCP by id</td>
  </tr>

  <tr>
      <td>DELETE</td><td>/network/dhcp/wins/:id</td><td>Delete wins server details from DHCP by id</td>
  </tr>

  <tr>
      <td>GET</td><td>/network/dhcp/:id</td><td>Show DHCP config info in VCG specified by ID</td>
  </tr>

</table>



*Network API*
==============

 List Network
--------------

    Verb   URI                 Description
    GET  /network/interfaces   List summary of network interfaces configured.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.


*Response*

```

    {
        "static": [
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


    Verb  URI	                Description
    POST	/network/interfaces      Create network interfaces configuration.

**Example Request and Response**

### Request JSON
         
    {
        "static": [
            {
                "device": "eth0",
                "inetaddr": "10.1.15.1",
                "netmask": "255.255.255.0",
                "broadcast": "169.254.255.255",
                "network": "169.254.255.255",
                "vlan": "vlan4",
                "hwaddress": "8c:89:a5:3d:f1:69",
                "gateway": "10.2.56.1",
                "up": {
                    "add": [
                        {
                            "net": "10.1.15.2",
                            "netmask": "255.255.255.0",
                            "gw": "10.1.15.1"
                         }
                    ]
                },
                "down": {
                    "del": [
                        {
                            "net": "10.1.15.3",
                            "netmask": "255.255.255.0",
                            "gw": "10.1.15.4"
                        }
                    ]
                }
            }
        ]
    }

### Response JSON

    {
        "result": "success"
    }


List a Network 
--------------

    Verb	URI	                   Description
    GET	/network/interfaces/:id	 Describes an configured network by name.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.


*Response*

```

    {
        "device": "eth0",
        "status": "active",
        "txbytes": "72013",
        "rxbytes": "72013"
    }

```



Delete a network
----------------

    Verb	  URI	                     Description
    DELETE /network/interfaces/:id	   Delete an configured network by name.

On Success returns 200 with JSON data

*TODO: Return appropriate error code and description in case of failure.*

**Example Request and Response**

### Request Headers

    DELETE /network/interfaces/eth0

### Response JSON

    {
        "result": "success"
    }


Configure subnet details for DHCP
---------------------------------

    Verb  URI	      		 Description
    POST	/network/dhcp/subnet	 Update subnet details for DHCP in VCG.

On success it returns JSON data with the service-id, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
           "start": "192.168.0.20",
           "end": "192.168.0.254",
           "interface": "eth0",
           "max_leases": 254,
           "remaining": "yes",
           "auto_time": 7200,
           "decline_time": 3600,
           "conflict_time": 3600,
           "offer_time": 60,
           "min_lease": 60,
           "lease_file": "/var/lib/misc/udhcpd.leases",
           "pidfile": "/var/run/udhcpd.pid",
           "notify_file": "dumpleases",
           "siaddr": "192.168.0.22",
           "sname": "zorak",
           "boot_file": "/var/lib/misc/udhcpd.leases",
           "option": ["subnet 192.168.0.25",
                      "timezone IST"]     
    }

### Response JSON


    {
      "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
      "config":
      {
           "start": "192.168.0.20",
           "end": "192.168.0.254",
           "interface": "eth0",
           "max_leases": 254,
           "remaining": "yes",
           "auto_time": 7200,
           "decline_time": 3600,
           "conflict_time": 3600,
           "offer_time": 60,
           "min_lease": 60,
           "lease_file": "/var/lib/misc/udhcpd.leases",
           "pidfile": "/var/run/udhcpd.pid",
           "notify_file": "dumpleases",
           "siaddr": "192.168.0.22",
           "sname": "zorak",
           "boot_file": "/var/lib/misc/udhcpd.leases",
           "option": ["subnet 192.168.0.25",
                      "timezone IST"]     
      }      
    }

Upon error, error code 500 will be returned


Describe subnet details in DHCP 
-------------------------------

    Verb	URI	                   Description
    GET	/network/dhcp/subnet/:id	 Describe the subnet config in DHCP by id.

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/subnet/85108146-6233-42d9-8f1c-2c8fca63f236

### Response JSON


    {
      "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
      "config":
      {
           "start": "192.168.0.20",
           "end": "192.168.0.254",
           "interface": "eth0",
           "max_leases": 254,
           "remaining": "yes",
           "auto_time": 7200,
           "decline_time": 3600,
           "conflict_time": 3600,
           "offer_time": 60,
           "min_lease": 60,
           "lease_file": "/var/lib/misc/udhcpd.leases",
           "pidfile": "/var/run/udhcpd.pid",
           "notify_file": "dumpleases",
           "siaddr": "192.168.0.22",
           "sname": "zorak",
           "boot_file": "/var/lib/misc/udhcpd.leases",
           "option": ["subnet 192.168.0.25",
                      "timezone IST"]     
      }      
    }




Delete subnet  details from DHCP
--------------------------------

    Verb	URI	                           Description
    DELETE      /network/dhcp/subnet/:id     Delete subnet details from DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/subnet/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }
    

Configure router details for DHCP
---------------------------------

    Verb        URI	   	 Description
    POST	/network/dhcp/router	 Update router configuration for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "router",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
           "optionparam": "router",
           "address": [
           "192.10.0.40",
           "192.10.0.41"
         ]
        } 
    }


Upon error, error code 500 will be returned


Describe router details in DHCP
-------------------------------
    Verb    URI	                    Description
    GET  /network/dhcp/router/:id 	  Describe router details in DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/router/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
           "optionparam": "router",
           "address": [
           "192.10.0.40",
           "192.10.0.41"
         ]
        } 
    }


Delete router details from DHCP
-------------------------------

    Verb    URI	                       Description
    DELETE  /network/dhcp/router/:id     Delete router details from DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/router/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Configure time server  details for DHCP
---------------------------------------

    Verb    URI        		 Description
    POST    /network/dhcp/timesvr	 Update time server details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "timesvr",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
         ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
         "config":
         {
            "optionparam": "timesvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }
    }


Upon error, error code 500 will be returned


Describe time server details for DHCP
-------------------------------------

    Verb    URI	                       Description
    GET     /network/dhcp/timesvr/:id    Describe time server details for DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/timesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
         "config":
         {
            "optionparam": "timesvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }
    }


Delete time server details from DHCP configuration
--------------------------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/timesvr/:id     Delete time server details from DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/timesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }




Configure name server details for DHCP
--------------------------------------

    Verb    URI        		 Description
    POST    /network/dhcp/namesvr	 Update the name server details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "namesvr",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
            "optionparam": "namesvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
           ]
        }
    }


Upon error, error code 500 will be returned



Describe name server details in DHCP
------------------------------------

    Verb    URI	                      Description
    GET /network/dhcp/namesvr/:id       Describe name server details for DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/namesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
            "optionparam": "namesvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
           ]
        }
    }



Delete name server details from DHCP
------------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/namesvr/:id     Delete name server details from DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/namesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Configure dns details for DHCP
-----------------------------

    Verb    URI      		      Description
    POST    /network/dhcp/dns  	      Update dns details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "dns",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        {
            "optionparam": "dns",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }


Upon error, error code 500 will be returned




Describe dns details in DHCP 
----------------------------

    Verb    URI	                  Description
    GET  /network/dhcp/dns/:id 	Describe dns details in DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/dns/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        {
            "optionparam": "dns",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }



Delete dns details from DHCP
---------------------------

    Verb    URI	                    Description
    DELETE  /network/dhcp/dns/:id 	  Delete dns details from DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/dns/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }




Configure log server details for DHCP
-------------------------------------

    Verb    URI        		 Description
    POST    /network/dhcp/logsvr	 Update log server details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "logsvr",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
            "optionparam": "logsvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }


Upon error, error code 500 will be returned


Describe log server details for DHCP
------------------------------------

    Verb    URI	                         Description
    GET     /network/dhcp/logsvr/:id       Describe log server details for DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/logsvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
            "optionparam": "logsvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }

Delete log server details from DHCP
-----------------------------------

    Verb    URI	                       Description
    DELETE  /network/dhcp/logsvr/:id     Delete log server details from DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/logsvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }





Configure cookie server details for DHCP
----------------------------------------

    Verb    URI        		 Description
    POST    /network/dhcp/cookiesvr	 Update the cookie server details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "cookiesvr",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
         ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config": 
        {
            "optionparam": "cookiesvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }
    }


Upon error, error code 500 will be returned


Describe cookie server details for DHCP
---------------------------------------

    Verb   URI	                          Description
    GET    /network/dhcp/cookiesvr/:id      Describe cookie server details for DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/cookiesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config": 
        {
            "optionparam": "cookiesvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }
    }


Delete cookie server details from DHCP
--------------------------------------

    Verb    URI	                          Description
    DELETE  /network/dhcp/cookiesvr/:id     Delete cookie server config from DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/cookiesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }




COnfigure lpr server details for DHCP
-------------------------------------

    Verb    URI          	         Description
    POST    /network/dhcp/lprsvr	Update lpr server details for dhcp in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "lprsvr",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
            "optionparam": "lprsvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }
    }


Upon error, error code 500 will be returned




Describe lpr server details for DHCP
------------------------------------

    Verb    URI	                   Description
    GET  /network/dhcp/lprsvr/:id 	 Describe lpr server config for DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/lprsvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config":
        {
            "optionparam": "lprsvr",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }
    }


Delete lpr server details from DHCP
-----------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/lprsvr/:id      Delete lpr server details from DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/lprsvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Configure ntp server details for DHCP
--------------------------------------

    Verb    URI          	        Description
    POST    /network/dhcp/ntpsrv	Update ntp server details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "ntpsrv",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config:
        {
            "optionparam": "ntpsrv",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }


Upon error, error code 500 will be returned



Describe ntp server details for DHCP
------------------------------------

    Verb    URI	                    Description
    GET  /network/dhcp/ntpsrv/:id 	  Describe ntp server details for DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    GET  /network/dhcp/ntpsrv/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config:
        {
            "optionparam": "ntpsrv",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }



Delete ntp server config from DHCP
----------------------------------

    Verb    URI	                      Description
    DELETE  /network/dhcp/ntpsrv/:id    Delete ntp server details from DHCP by id.


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/ntpsrv/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }




Configure wins server details for DHCP
--------------------------------------

    Verb    URI          	        Description
    POST    /network/dhcp/wins     Update wins server details for DHCP in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
        "optionparam": "wins",
        "address": [
        "192.10.0.40",
        "192.10.0.41"
        ]
    }

### Response JSON

    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config:
        {
            "optionparam": "wins",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }

Upon error, error code 500 will be returned


Describe wins server details for DHCP
-------------------------------------

    Verb    URI	                    Description
    Get  /network/dhcp/wins/:id 	  Describe wins server details for DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/wins/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON


    {
        "id": "85108146-6233-42d9-8f1c-2c8fca63f236",
        "config:
        {
            "optionparam": "wins",
            "address": [
            "192.10.0.40",
            "192.10.0.41"
            ]
        }

    }


Delete wins details from DHCP
-----------------------------

    Verb    URI	                    Description
    DELETE  /network/dhcp/wins/:id 	  Delete win server details from DHCP by id.

On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/wins/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }





Describe DHCP 
--------------

    Verb    URI	                  Description
    GET	    /network/dhcp/:id	Show DHCP config info in VCG specified by id.
**Example Request and Response**

### Request Headers

    GET /network/dhcp/2da8f435-42c1-45d2-9fad-04fdf7298c80

### Response JSON

    {
            "key":"2da8f435-42c1-45d2-9fad-04fdf7298c80",
            "val":
              {
                   "start":"192.168.0.20",
                    "end":"192.168.0.254",
                    "interface":"eth0",
                    "max_leases":254,
                    "remaining":"yes",
                    "auto_time":7200,
                    "decline_time":3600,
                    "conflict_time":3600,
                    "offer_time":60,
                    "min_lease":60,
                    "lease_file":"/var/lib/misc/udhcpd.leases",
                    "pidfile":"/var/run/udhcpd.pid",
                    "notify_file":"dumpleases",
                    "siaddr":"192.168.0.22",
                    "sname":"zorak",
                    "boot_file":"/var/lib/misc/udhcpd.leases",
                    "option":
                    [
                      "subnet 192.168.0.25",
                      "timezone IST"
                    ]
                }
    }
    

Please note that the top-level `id` returned above refers to the service-ID.

Upon error, error code 500 will be returned

