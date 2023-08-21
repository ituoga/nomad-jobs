job "cftunnel" {
  type = "service"
  group "cftunnel" {
    task "cftunnel" {
      driver = "docker"

      config {
        image        = "cloudflare/cloudflared:latest"
        command      = "tunnel"
        args         = ["--loglevel", "debug", "--transport-loglevel", "debug", "--no-autoupdate", "run", "--token", "$CFTOKEN"]
        network_mode = "nomad_network"
      }

      resources {
        cpu    = 100
        memory = 256
      }

      template {
        data = <<EOF
CFTOKEN=[get token from nomad env, consul or vaul]
EOF
        destination = "secrets/cftunnel.env"
        env = true
      }
    }
  }
}