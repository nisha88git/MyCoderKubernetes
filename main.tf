terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    coder = {
      source  = "coder/coder"
      version = "~> 0.9"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "coder" {}

data "coder_workspace" "me" {}

resource "kubernetes_pod" "dev" {
  metadata {
    name      = "ws-${data.coder_workspace.me.user_id}-${data.coder_workspace.me.name}"
    namespace = "default"
    labels = {
      app = "coder-workspace"
    }
  }

  spec {
    container {
      name    = "ubuntu-dev"
      image   = "ubuntu:22.04"
      command = ["/bin/sh", "-c", "while true; do sleep 30; done"]

      resources {
        requests = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }

      tty = true
      stdin = true
    }

    restart_policy = "Always"
  }
}
