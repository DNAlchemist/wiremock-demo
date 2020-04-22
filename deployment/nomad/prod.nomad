job "smsaero-wiremock" {
  datacenters = [
    "dc1"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "60s"
    healthy_deadline = "20s"
    progress_deadline = "30s"
    auto_revert = false
    canary = 0
  }

  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "20m"
  }

  group "service" {
    count = 1
    ephemeral_disk {
      size = 1024
    }

    constraint {
      attribute = "${attr.unique.hostname}"
      operator = "regexp"
      value = ".*app.*"
    }

    restart {
      attempts = 3
      delay = "30s"
      interval = "5m"
      mode = "delay"
    }

    task "docker" {
      driver = "docker"
      config {
        image = "nexus.service.consul:5000/kafka-reader-web"
        volumes = [
          "tmp:/tmp"
        ]
        port_map {
          http = 8080
        }
      }

      resources {
        cpu = 300
        memory = 768
        network {
          mbits = 1
        }
      }

      service {
        name = "smsaero-wiremock"
        tags = [
          "api"
        ]
        port = "http"
      }

    }
  }
}
