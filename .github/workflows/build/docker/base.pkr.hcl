packer {
  required_plugins {
    docker = {
      version = ">= 1.0.5"
      source  = "github.com/hashicorp/docker"
    }
  }
}
