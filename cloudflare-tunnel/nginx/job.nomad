job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 3
    network {
      port "http" {
        to = 80
      }
    }
    task "nginx" {
      driver = "docker"

      config {
        image        = "nginx:1.13.6-alpine"
        ports        = ["http"]
        network_mode = "nomad_network"
        volumes = [
          "local/index.html:/usr/share/nginx/html/index.html"
        ]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

      }
      service {
        name         = "nginx"
        provider     = "nomad"
        address_mode = "auto"
        port         = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_ALLOC_ID}.entrypoints=web",
          "traefik.http.routers.${NOMAD_ALLOC_ID}.rule=Host(`penki.domain.tld`)"
        ]
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