# Nomad CloudFlare Tunnel

This is very basic example how you can run Zero Trust Tunnel on nomad to proxy *.domain.tld to your nomad setup without exposing any ports 


cftunnel - docker container with params from cloudflare tunnel config
nginx - real app 
traefik - internal load balancer


//TODO: explain how to create wildcard CloudFlare tunnel

//TODO: consul connect version


Docker network variant (defined in jobs): 

`
docker network create --driver=bridge --subnet=192.168.255.0/24 --ip-range=192.168.255.0/25 --gateway=192.168.255.1 nomad_network
`

Weave networks variant ( alternative way ):
if you want to run this on few server, you can use "weave" overlay network. Here is example of how to start it:

download weave script
```
sudo curl -L git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave
```

then, define your IP ranges. Full net with /16 and and for IPAM - /17, so we could use upper half for manual IPs

`weave launch --ipalloc-range 10.255.0.0/16 --ipalloc-default-subnet 10.255.255.0/17 --password [topsecretpasswordtoconnect] [server1ip] [server2ip]`

if you run this command on sencond server, you need to specify first server ip so weave could connect it and make single network.

once you have weave network up and running - you can specify "weave" network_mode instead of created "docker_network"
