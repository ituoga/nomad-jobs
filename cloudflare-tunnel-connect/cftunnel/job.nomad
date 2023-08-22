job "cftunnel" {
  type = "service"

  group "cftunnel" {

    network {
      mode = "bridge"
    }

    service {
      name         = "cftunnel"
      provider     = "consul"
      address_mode = "auto"
      tags         = ["traefik.enable=true"]
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "traefik-consul"
              local_bind_port  = 8080
            }
          }
        }
      }
    }

    task "cftunnel" {
      driver = "docker"

      config {
        privileged = true
        image      = "cloudflare/cloudflared:latest"
        command    = "tunnel"
        args       = ["--no-autoupdate", "run", "--token", "$TOKEN"]
      }

      resources {
        cpu    = 100
        memory = 256
      }
      template {
        destination = "local/cftunnel.hcl"
        data        = <<EOF
TOKEN=[get token from nomad vars, consul kv or vault]
EOF
      }
    }
  }
}