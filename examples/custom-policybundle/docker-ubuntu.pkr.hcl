packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
    cnspec = {
      version = ">= 8.0.0"
      source  = "github.com/mondoohq/cnspec"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:xenial"
  commit = true
}

build {
  name = "learn-packer"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "cnspec" {
    on_failure =  "continue"
    policybundle = "custom-policy.mql.yaml" 
  }
}
