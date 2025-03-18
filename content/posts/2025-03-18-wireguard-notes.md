---
date: 2025-03-18 21:06:24+0000
slug: 2025-03-18-wg-notes
title: WireGuard notes
categories:
    - software
    - networks
    - vpn
---

Wireguard (_abbrev_ WG below) is a modern VPN solution that ships by default on modern Linux-es and is easily installable on Windows/Mac/BSD etc., It is written [by a security expert](https://www.reddit.com/r/linux/comments/hzyu8j/im_jason_a_donenfeld_security_researcher_kernel/?rdt=64706), and uses an easily explainable architecture to try and avoid security vulnerabilities.

It builds on primitives like network tunnelling interfaces and namespaces on Linux -   by adding a layer of authentication and encryption to traffic as you'd expect from a VPN solution. WG in server mode uses port 51820/udp by default and this must be available to any clients that need to connect.  The same WG binary works either as a server or a client, depending on how you set it up.

You create network interfaces that have (elliptic curve) private keys associated with them. You share public keys with everyone that needs to connect. That's pretty much it. Everything else is up to you.  More details on the cryptographic primitives used by Wireguard are [available here.](https://www.wireguard.com/papers/wireguard.pdf) My overall impression of it is that WG doesn't attempt to re-invent the wheel, instead it extends on well known (or well reviewed) building blocks for its design. The trade-off is that it doesn't try to do a whole lot of things that other complex VPN software might try to do.
  
There are some out of the box challenges for new users, and these are not directly addressed by Wireguard as explicit design goals. Key generation and sharing public keys used for communication are a user's responsibility.  This is not particularly difficult to do - but I can see it get daunting if you have to do this for large networks with complex topologies.  There are third party solutions like [Tailscale](https://tailscale.com)  that build on Wireguard to make it easier to use by automating the sharing of keys and providing additional features such as access-control lists, cool DNS stuff to allow/disallow different types of traffic flows. I've used Tailscale a lot for personal stuff, and you don't need to know anything about WG to use it - the UX is very slick. 

WG shines for well defined setups where you know exactly who the servers are and who are going to be the clients, and you don't need to implement any fussy authorisation controls. 

Assume that we have this scenario:
1. Server that is on the internet on `1.2.3.4` which we want to connect to securely. The IP address might change at some point - but the client should be able to reach at it _initially_ before it can receive any encrypted traffic from the server.
2. A client whose IP is not fixed since they may be travelling or switching between connection paths

### Setup 
The config file is usually `/etc/wireguard/wg0.conf` or the equivalent on different OSes. You can have multiple WG interfaces if you need them.

- The server generates a key-pair. The private key stays on the server and is added to the `wg.conf` file. You have to be extra-careful to lock down access to this file. The server's public key needs to be shared with the client. WG doesn't provide any mechanisms to do share either client or server public keys. The keys are small (ECC) so you could share them via text messages or QR codes. 
- The client generates a key-pair. The private key lives on the client, public key must be shared with the server. 

Once we have the server and client set up with keys. Here's what the server's config looks like (you can optionally add `DNS=<your dns server>` to tell WG to use a particular DNS server to resolve IP addresses):

```
[Interface]
PrivateKey = the server's private key
ListenPort = 51820
  

[Peer]
PublicKey = the client's public key
AllowedIPs = 10.192.122.3/32
```

  
 Client's config: 

```
[Interface]
PrivateKey = the client's private key
ListenPort = 21841

[Peer]
PublicKey = the server's public key
Endpoint = 1.2.3.4:51820
AllowedIPs = 0.0.0.0/0
```


From the docs (emphasis mine):

> At the heart of WireGuard is a concept called _**Cryptokey Routing**_, which works by associating public keys with a list of tunnel IP addresses that are allowed inside the tunnel. Each network interface has a private key and a list of peers. Each peer has a public key. Public keys are short and simple, and are used by peers to authenticate each other. They can be passed around for use in configuration files by any out-of-band method, similar to how one might send their SSH public key to a friend for access to a shell server.

So let's say a server receives a packet on port 51820. What happens next?
- The WG service attempts to decrypt & authenticate the packet using the server's private key. If this fails, the traffic is dropped
- The WG service decrypts the packet successfully, then it checks if the source IP of the encapsulated packet matches the AllowedIPs. In our configuration, we only allow `10.192.122.3/32` so if the source IP doesn't match, the packet is dropped
- If the packet can be authenticated, decrypted AND is allowed in `AllowedIPs` the traffic is allowed on to the interface

For the client, when it receives a packet on port 21841, the WG service performs the exact steps as above. 

The docs explain this very clearly (emphasis mine with changes to mirror our setup above)

> In the server configuration, each peer (a client) will be able to send packets to the network interface with a source IP matching his corresponding list of allowed IPs. For example, when a packet is received by the server from peer with `client public key`, after being decrypted and authenticated, if its source IP is **10.192.122.3/32**, then it's allowed onto the interface; otherwise it's dropped.

  
> In the server configuration, when the network interface wants to send a packet to a peer (a client), it looks at that packet's destination IP and compares it to each peer's list of allowed IPs to see which peer to send it to. For example, if the network interface is asked to send a packet with a destination IP of **10.192.122.3/32**, it will encrypt it using the public key of peer `client public key`, and then send it to that **peer's most recent Internet endpoint.** (_the server keeps track of the internet endpoints used by a client_)


>In the client configuration, its single peer (the server) will be able to send packets to the network interface with _any_ source IP (since 0.0.0.0/0 is a wildcard). For example, when a packet is received from peer `server public key`, if it decrypts and authenticates correctly, with any source IP, then it's allowed onto the interface; otherwise it's dropped.

>In the client configuration, when the network interface wants to send a packet to its single peer (the server), it will encrypt packets for the single peer **with _any_ destination IP address** (since 0.0.0.0/0 is a wildcard). For example, if the network interface is asked to send a packet with any destination IP, it will encrypt it using the public key of the single peer `server public key`, and then send it to the single **peer's most recent Internet endpoint** (_the client keeps track of the internet endpoints used by a server_).

>In other words, when sending packets, the list of allowed IPs behaves as a sort of routing table, and when receiving packets, the list of allowed IPs behaves as a sort of access control list.

> This is what we call a _Cryptokey Routing Table_: the simple association of public keys and allowed IPs.

We've hard-coded IP address ranges in our config for the client (**1.2.3.4:51820**) so what happens if this changes? 

Again quoting the venerable docs (emphasis mine)

>The client configuration contains an _initial_ endpoint of its single peer (the server), so that it knows where to send encrypted data **before it has received encrypted data.** The server configuration doesn't have any initial endpoints of its peers (the clients). This is because the server discovers the endpoint of its peers by examining from where correctly authenticated data originates. If the server itself **changes its own endpoint, and sends data to the clients,** the clients will discover the new server endpoint and update the configuration just the same. Both client and server send encrypted data to the most recent IP endpoint for which they authentically decrypted data. Thus, there is full IP roaming on both ends.

So we have two tunnels that can receive and send and receive encrypted and authenticated traffic. 

But, how does a tunnel work with existing network interfaces? Why do you need one, anyway?

On a Linux system, you might have interfaces like `wlan0` or `eth0`. When your application tries to send data, it needs to be routed to the right network somehow. If your wireless network has the range `192.168.1.1/24` and your wired network has the range `10.10.10.10/24` your computer's local route table decides where the traffic goes depending on how specific the route is in your route table (e.g. `192.168.1.1/32` is specific, `0.0.0.0/0` is not) 

You can do this for WG too, by adding specific routes (recall that more specific routes have higher precedence) for when you want traffic to go the wireguard TUN (tunnel) interface. This can be fragile, though, if your network configuration changes and you'll need to fix the route. 

WG uses a clever way that makes use of the network namespaces feature to allow applications to route all traffic through it. You can read about [it in detail](https://www.wireguard.com/netns/), it is pretty cool! The idea here is that this makes it more resilient to route table/network changes and allows you to easily tunnel all traffic through it.

### What about DNS?
I've managed to write all of this without mentioning DNS in any detail. DNS is the root of all evil bugs, but WG does offer a way to use DNS as part of your configuration which I've pointed out above. I might cover that in a later post if I run into a DNS issue - which is probably going to be sooner rather than later. 
  
### What about split tunneling?
I don't fully understand the mechanics of split tunneling and haven't learned enough about it. My _gut feeling_ is that since servers use AllowedIPs as a sort of routing table, it should be possible to set-up. 
