variable "bs" {
    default = "no"
    type = string
}

job "mariadb-galera" {
  type = "service"

  meta {
    version = "1"
  }

  group "galera-cluster-1" {
    count = 1
    network {
      mode = "bridge"
      port "mysql" {
        to = 3306
      }
    }

    service {
      name         = "mariadb-galera-1-connect-2"
      port         = "3307"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mariadb-galera-2-gcomm"
              local_bind_port  = 45672
            }
          }
        }
      }
    }
    service {
      name         = "mariadb-galera-1-connect-3"
      port         = "3307"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mariadb-galera-3-gcomm"
              local_bind_port  = 45673
            }
          }
        }
      }
    }

    service {
      name         = "mariadb-galera"
      port         = "3306"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
    }

    service {
      name         = "mariadb-galera-1-gcomm"
      port         = "4567"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
    }

    task "galera-cluster" {
      driver = "docker"

      env {
        ALLOW_EMPTY_PASSWORD                 = "yes"
        MARIADB_ROOT_PASSWORD                = "my-root-password"
        MARIADB_DATABASE                     = "mydatabase"
        MARIADB_REPLICATION_USER             = "my-replication-user"
        MARIADB_REPLICATION_PASSWORD         = "my-replication-password"
        MARIADB_GALERA_CLUSTER_NAME          = "my-test-cluster"
        MARIADB_GALERA_CLUSTER_ADDRESS       = "gcomm://127.0.0.1:45672,127.0.0.1:45673"
        MARIADB_GALERA_CLUSTER_BOOTSTRAP     = "${var.bs}"
        MARIADB_GALERA_FORCE_SAFETOBOOTSTRAP = "${var.bs}"
      }

      user = "root"

      config {
        image      = "bitnami/mariadb-galera:latest"
        privileged = true
        volumes = [
          "/nomad/db1:/bitnami/mariadb"
        ]
      }

      resources {
        cpu    = 200
        memory = 400
      }
    }
  }





  group "galera-cluster-2" {
    count = 1
    network {
      mode = "bridge"
      port "mysql" {
        to = 3306
      }
    }

    service {
      name         = "mariadb-galera-2-connect-1"
      port         = "3307"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mariadb-galera-1-gcomm"
              local_bind_port  = 45671
            }
          }
        }
      }
    }
    service {
      name         = "mariadb-galera-2-connect-3"
      port         = "3307"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mariadb-galera-3-gcomm"
              local_bind_port  = 45673
            }
          }
        }
      }
    }

    service {
      name         = "mariadb-galera"
      port         = "3306"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
    }

    service {
      name         = "mariadb-galera-2-gcomm"
      port         = "4567"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
    }

    task "galera-cluster" {
      driver = "docker"

      env {
        ALLOW_EMPTY_PASSWORD                 = "yes"
        MARIADB_ROOT_PASSWORD                = "my-root-password"
        MARIADB_DATABASE                     = "mydatabase"
        MARIADB_REPLICATION_USER             = "my-replication-user"
        MARIADB_REPLICATION_PASSWORD         = "my-replication-password"
        MARIADB_GALERA_CLUSTER_NAME          = "my-test-cluster"
        MARIADB_GALERA_CLUSTER_ADDRESS       = "gcomm://127.0.0.1:45671,127.0.0.1:45673"
        MARIADB_GALERA_CLUSTER_BOOTSTRAP     = "no"
        MARIADB_GALERA_FORCE_SAFETOBOOTSTRAP = "no"
      }

      user = "root"

      config {
        image      = "bitnami/mariadb-galera:latest"
        privileged = true
        volumes = [
          "/nomad/db2:/bitnami/mariadb"
        ]
      }

      resources {
        cpu    = 200
        memory = 400
      }
    }
  }


  group "galera-cluster-3" {
    count = 1
    network {
      mode = "bridge"
      port "mysql" {
        to = 3306
      }
    }

    service {
      name         = "mariadb-galera-3-connect-1"
      port         = "3307"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mariadb-galera-1-gcomm"
              local_bind_port  = 45671
            }
          }
        }
      }
    }
    service {
      name         = "mariadb-galera-3-connect-2"
      port         = "3307"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mariadb-galera-2-gcomm"
              local_bind_port  = 45672
            }
          }
        }
      }
    }

    service {
      name         = "mariadb-galera"
      port         = "3306"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
    }

    service {
      name         = "mariadb-galera-3-gcomm"
      port         = "4567"
      provider     = "consul"
      address_mode = "auto"
      connect {
        sidecar_service {}
      }
    }

    task "galera-cluster" {
      driver = "docker"

      env {
        ALLOW_EMPTY_PASSWORD                 = "yes"
        MARIADB_ROOT_PASSWORD                = "my-root-password"
        MARIADB_DATABASE                     = "mydatabase"
        MARIADB_REPLICATION_USER             = "my-replication-user"
        MARIADB_REPLICATION_PASSWORD         = "my-replication-password"
        MARIADB_GALERA_CLUSTER_NAME          = "my-test-cluster"
        MARIADB_GALERA_CLUSTER_ADDRESS       = "gcomm://127.0.0.1:45671,127.0.0.1:45672"
        MARIADB_GALERA_CLUSTER_BOOTSTRAP     = "no"
        MARIADB_GALERA_FORCE_SAFETOBOOTSTRAP = "no"
      }

      user = "root"

      config {
        image      = "bitnami/mariadb-galera:latest"
        privileged = true
        volumes = [
          "/nomad/db3:/bitnami/mariadb"
        ]
      }

      resources {
        cpu    = 200
        memory = 400
      }
    }
  }

}