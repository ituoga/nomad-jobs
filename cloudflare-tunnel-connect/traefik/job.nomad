job "traefik" {
  type = "service"
  meta {
    version = "1"
  }
  group "traefik" {
    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
    }
    service {
      name         = "traefik"
      tags         = ["traefik.enable=true"]
      port         = "http"
      provider     = "consul"
      address_mode = "auto"
      connect {
        native = true
      }
    }
    service {
      name         = "traefik-consul"
      port         = "8080"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
      tags = ["traefik.enable=true"]
    }

    task "traefik" {
      driver = "docker"

      config {
        privileged = true
        image      = "shoenig/traefik:connect"
        ports      = ["http"]
        args = [
          "--providers.consulcatalog.connectaware=true",
          "--providers.consulcatalog.connectbydefault=true",
          "--providers.consulcatalog.exposedbydefault=true",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--serverstransport.insecureskipverify=true",
          "--log.level=DEBUG",
          "--api.insecure=true",
          "--entrypoints.web.address=0.0.0.0:${NOMAD_PORT_http}",
        ]
      }
    }
  }
}