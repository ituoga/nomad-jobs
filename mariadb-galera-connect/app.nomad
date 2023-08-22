job "app" {
    group "php" {
    count = 1
    network {
      port "http" {
        to = 80
      }
      mode = "bridge"
    }
    service {
        name = "php-database"
        provider = "consul" 
        port = "3306"
        connect {
            sidecar_service {
                proxy {
                    upstreams {
                        destination_name = "mariadb-galera"
                        local_bind_port = 3306
                    }
                }
            }
        }
    }
    service {
      name         = "php-app"
      provider     = "consul"
      address_mode = "auto"
      port         = "80"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_ALLOC_ID}.entrypoints=web",
        "traefik.http.routers.${NOMAD_ALLOC_ID}.rule=Host(`subdomain.dom.tld`)"
      ]
      connect {
        sidecar_service {}
      }
    }
    task "php" {
      driver = "docker"

      config {
        image        = "spiksius/php8.1-apache"
        ports        = ["80"]
        volumes = [
          "local/index.php:/var/www/html/index.php",
          "local/index.php:/var/www/public/index.php"
        ]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

      }

      template {
        data        = <<EOF
<pre>
<?php
$link = mysqli_connect("127.0.0.1", "root", "my-root-password", "mydatabase");
$res = mysqli_query($link, "show databases");
while ($row = mysqli_fetch_assoc($res)) {
    print_r($row);
    echo "\n";
}
EOF
        destination = "local/index.php"
        perms       = "0755"
      }

    }
  }
}