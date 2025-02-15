packer {
  required_version = "~> 1.8.0"

  required_plugins {
    amazon = {
      version = "~> 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
