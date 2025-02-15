packer {
  required_version = "~> 1.12.0"

  required_plugins {
    git = {
      version = ">=v0.3.2"
      source  = "github.com/ethanmdavidson/git"
    }
    bakery = {
      version = "v0.0.2"
      source  = "github.com/bryborge/sbc-bakery"
    }
  }
}
