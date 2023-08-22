job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 3
    network {
      port "http" {
        to = 80
      }
      mode = "bridge"
    }

    service {
      name         = "nginx"
      provider     = "consul"
      address_mode = "auto"
      port         = "80"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_ALLOC_ID}.entrypoints=web",
        "traefik.http.routers.${NOMAD_ALLOC_ID}.rule=Host(`domain.dom.tld`)"
      ]
      connect {
        sidecar_service {}
      }
    }
    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:1.13.6-alpine"
        ports = ["http"]
        volumes = [
          "local/index.html:/usr/share/nginx/html/index.html"
        ]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

      }

      template {
        data        = <<EOF
{{ env "NOMAD_ALLOC_ID" }}
EOF
        destination = "local/index.html"
        perms       = "0755"
      }
    }
  }
}