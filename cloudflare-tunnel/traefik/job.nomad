job "traefik" {
  type = "service"


  group "nomad-proxy" {

    // uncomment this and add on nomad server meta.roles = [nomad-proxy]
    // constraint {
    //   attribute = "${meta.roles}"
    //   operator  = "set_contains_any"
    //   value     = "nomad-proxy"
    // }

    // remove socket if exists
    task "hook" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image   = "alpine"
        command = "sh"
        mount {
          type     = "bind"
          target   = "/host/var/run"
          source   = "/dev/shm"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        args = [
          "-c",
          "rm -rf /host/var/run/sock.socket"
        ]
      }
    }

    // create socket from host nomad IP:PORT
    task "nomad-to-socket" {
      driver = "docker"
      config {
        image        = "alpine/socat"
        network_mode = "host"
        command      = "-T"
        args = [
          "2", "UNIX-LISTEN:/host/var/run/sock.socket,fork", "TCP-CONNECT:127.0.0.1:4646"
        ]
        mount {
          type     = "bind"
          target   = "/host/var/run"
          source   = "/dev/shm"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
      }
    }

    // create http proxy from shared socket on static IP
    // so we can specify on traefik nomad provider IP:PORT
    task "nomad-from-socket" {
      driver = "docker"
      config {
        image        = "alpine/socat"
        network_mode = "nomad_network"
        command      = "-T"
        args = [
          "2", "TCP-LISTEN:4646,fork", "UNIX-CONNECT:/host/var/run/sock.socket"
        ]
        ipv4_address = "192.168.255.250"
        mount {
          type     = "bind"
          target   = "/host/var/run"
          source   = "/dev/shm"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
      }
      service {
        name         = "nomad-proxy"
        provider     = "nomad"
        address_mode = "driver"
        port         = "4646"
        tags = [
          "traefik.enable=false", // disabled. enable if you want expose nomad via subdomain
          "traefik.http.routers.${NOMAD_ALLOC_ID}.rule=Host(`system.domain.tld`)",
          "traefik.http.routers.${NOMAD_ALLOC_ID}.entrypoints=web",
        ]
      }
    }
  }


  // we also need to specity static IP to traefic
  // so cloud flare tunner could now where to connect
  // if you use consul DNS you can play with internal .service.consul domain
  group "traefik" {
    network {
      port "http" {
        to = 80
      }
    }
    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:latest"
        ports        = ["http"]
        network_mode = "nomad_network"
        ipv4_address = "192.168.255.150"
        args = [
          "--serverstransport.insecureskipverify=true",
          "--log.level=DEBUG",
          "--api.insecure=true",
          "--entrypoints.web.address=:80",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://192.168.255.250:4646", // static IP of nomad proxy
          "--providers.nomad.prefix=traefik",
          "--providers.nomad.namespaces=default",
          "--providers.nomad.exposedbydefault=false"
        ]
      }
      service {
        name         = "traefik"
        tags         = ["traefik.enable=true"]
        port         = "http"
        provider     = "nomad"
        address_mode = "auto"
      }
    }
  }
}