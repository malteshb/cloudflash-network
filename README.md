cloudflash-network
==================


*List of interface APIs*
========================

<table>
  <tr>
    <th>Verb</th><th>URI</th><th>Description</th>
  </tr>
  <tr>
    <td>GET</td><td>/network/interfaces</td><td>List summary of network interfaces configured</td>
  </tr>
  <tr>
    <td>POST</td><td>/network/interfaces/:id</td><td>Create network a interfaces</td>
  </tr>
  <tr>
    <td>POST</td><td>/network/interfaces/:id/vlan/:vid</td><td>Create a VLAN network interface</td>
  </tr>
  <tr>
    <td>GET</td><td>/network/interfaces/:id</td><td>Describes an configured network by ID</td>
  </tr>
 <tr>
    <td>GET</td><td>/network/interfaces/:id/vlan</td><td>Describes configured VLAN network</td>
  </tr>
  <tr>
    <td>GET</td><td>/network/interfaces/:id/vlan/:vid</td><td>Describes a configured VLAN network by ID</td>
  </tr>

  <tr>
    <td>DELETE</td><td>/network/interfaces/:id</td><td>Delete an configured network by ID</td>
  </tr>
  <tr>
    <td>DELETE</td><td>/network/interfaces/:id/vlan/:vid</td><td>Delete an configured VLAN network by ID</td>
  </tr>
</table>



 List Network Interfaces
-------------------------

    Verb   URI                   Description
    GET    /network/interfaces   List summary of network interfaces configured.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.


*Response*

    

[

    {
        "id": "lo",
        "config": { },
        "stats": {
            "txbytes": "832529",
            "rxbytes": "832529"
        },
        "operstate": "unknown",
        "mtu": "16436",
        "devtype": "lo"
    },
    {
        "id": "eth1",
        "config": {
            "type": "static",
            "address": [
                "10.1.10.142"
            ],
            "netmask": "255.255.255.0",
            "gateway": "10.1.10.1",
            "broadcast": "10.1.10.255"
        },
        "stats": {
            "txbytes": "1139580",
            "rxbytes": "17212321"
        },
        "operstate": "up",
        "mtu": "1500",
        "devtype": "Ether"
    },
    {
        "id": "eth1.3",
        "config": {
            "type": "static",
            "address": "10.1.10.111",
            "netmask": "255.255.255.0",
            "gateway": "10.1.10.1",
            "broadcast": "10.1.10.255"
        },
        "stats": {
            "txbytes": "468",
            "rxbytes": "0"
        },
        "operstate": "down",
        "mtu": "1500",
        "devtype": "Ether"
    },
    {
        "id": "eth1.4",
        "config": {
            "type": "static",
            "address": "10.2.10.111",
            "netmask": "255.255.255.0",
            "gateway": "10.1.10.1",
            "broadcast": "10.1.10.255"
        },
        "stats": {
            "txbytes": "8358",
            "rxbytes": "0"
        },
        "operstate": "down",
        "mtu": "1500",
        "devtype": "Ether"
    },
    {
        "id": "eth1.5",
        "config": {
            "type": "dynamic",
            "dhcp": true
        },
        "stats": {
            "txbytes": "3546",
            "rxbytes": "0"
        },
        "operstate": "down",
        "mtu": "1500",
        "devtype": "Ether"
    },
    {
        "id": "eth1.6",
        "config": {
            "type": "dynamic",
            "dhcp": true
        },
        "stats": {
            "txbytes": "4230",
            "rxbytes": "0"
        },
        "operstate": "down",
        "mtu": "1500",
        "devtype": "Ether"
    }

]


Configure Network Interfaces
-----------------------------


    Verb    URI                            Description
    POST    /network/interfaces/eth1  Create network interfaces configuration.

**Example Request and Response**

### Request JSON For static
    {
        "type": "static",
        "address": [
            "10.1.10.142"
        ],:
        "netmask": "255.255.255.0",
        "gateway": "10.1.10.1",
        "broadcast": "10.1.10.255"
        "post-up": [
             "route add -net 10.10.10.0/24 gw 10.1.10.1"
         ]
    }

### Response JSON  
    {

        "id": "eth1",
        "config": {
            "type": "static",
            "address": [
                "10.1.10.142"
            ],
            "netmask": "255.255.255.0",
            "gateway": "10.1.10.1",
            "broadcast": "10.1.10.255"
            "post-up": [
             "route add -net 10.10.10.0/24 gw 10.1.10.1"
             ]
        }
    }

### Request JSON For dynamic
    
   {
        "dhcp": true,
        "type":"dynamic"
   }


### Response JSON  

    {
        "id": "eth1.6",
        "config": {
            "type": "dynamic",
            "dhcp": true
         }
    }

Configure VLAN Network Interfaces
---------------------------------


    Verb    URI                                Description
    POST    /network/interfaces/:ifid/vlan/:vid  Create network VLAN interfaces configuration.

**Example Request and Response**
POST /network/interfaces/eth1/vlan/4

### Request JSON For vlan
    {
        "type":"static", 
        "address":"10.2.10.111", 
        "netmask":"255.255.255.0", 
        "gateway":"10.1.10.1",
        "broadcast":"10.1.10.255"
    }

### Response JSON  
    {
        "id": "eth1.4",
        "config": {
           "type": "static",
           "address": "10.2.10.111",
           "netmask": "255.255.255.0",
           "gateway": "10.1.10.1",
           "broadcast": "10.1.10.255"
        }
    }

List a Network Interface
------------------------

    Verb    URI                          Description
    GET   /network/interfaces/:id      Describes an configured network by name.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.

GET /network/interfaces/eth1

*Response*    
   {

        "id": "eth1",
        "config": {
           "type": "static",
           "address": [
              "10.1.10.142"
           ],
           "netmask": "255.255.255.0",
           "gateway": "10.1.10.1",
           "broadcast": "10.1.10.255"
        },
        "stats": {
           "txbytes": "1152289",
           "rxbytes": "17325196"
        },
        "operstate": "up",
        "mtu": "1500",
        "devtype": "Ether"

   }

GET /network/interfaces/eth1.4

*Response*

   {

        "id": "eth1.4",
        "config": {
           "type": "static",
           "address": "10.2.10.111",
           "netmask": "255.255.255.0",
           "gateway": "10.1.10.1",
           "broadcast": "10.1.10.255"
        },
        "stats": {
           "txbytes": "8358",
           "rxbytes": "0"
        },
        "operstate": "down",
        "mtu": "1500",
        "devtype": "Ether"

    }

List VLAN Network Interface 
----------------------------

    Verb    URI                             Description
    GET   /network/interfaces/:id/vlan      Describes configured VLAN network.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.

GET /network/interfaces/eth1/vlan

*Response*    
   [

        {
           "id": "eth1.3",
           "config": {
              "type": "static",
              "address": "10.1.10.111",
              "netmask": "255.255.255.0",
              "gateway": "10.1.10.1",
              "broadcast": "10.1.10.255"
            },
            "stats": {
              "txbytes": "468",
              "rxbytes": "0"
            },
            "operstate": "down",
            "mtu": "1500",
            "devtype": "Ether"
        },
        {
            "id": "eth1.5",
            "config": {
               "type": "dynamic",
               "dhcp": true
             },
             "stats": {
                "txbytes": "3546",
                "rxbytes": "0"
             },
             "operstate": "down",
             "mtu": "1500",
             "devtype": "Ether"
         }
   ]


List a VLAN Network Interface
-----------------------------

    Verb    URI                                  Description
    GET   /network/interfaces/:id/vlan/:vid      Describes a configured VLAN network by ID.


Note: The request does not require a message body.
Success: Returns JSON data with list of network configured.

GET /network/interfaces/eth1/vlan/4

*Response*
    
    {
        "id": "eth1.4",
        "config": {
           "type": "static",
           "address": "10.2.10.111",
           "netmask": "255.255.255.0",
           "gateway": "10.1.10.1",
           "broadcast": "10.1.10.255"
        },
        "stats": {
           "txbytes": "8358",
           "rxbytes": "0"
        },
        "operstate": "down",
        "mtu": "1500",
        "devtype": "Ether"

    }
    


Delete a network interface
----------------

    Verb    URI                          Description
    DELETE    /network/interfaces/:id	   Delete an configured network by name.


**Example Request and Response**

### Request Headers

    DELETE /network/interfaces/eth0

### Response Header

   Status Code : 204


Delete a VLAN network interface
--------------------------------

    Verb    URI                                     Description
    DELETE    /network/interfaces/:id/vlan/:vid	   Delete an configured VLAN network by VLAN ID.

**Example Request and Response**

### Request Headers

    DELETE /network/interfaces/eth0/vlan/1

### Response Header

   Status Code : 204



