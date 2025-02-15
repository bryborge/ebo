
data "git-commit" "cwd-head" {}

locals {
  git_sha = data.git-commit.cwd-head.hash
}

build {
  sources = ["source.bakery-sbc-builder.ubuntu"]

  provisioner "shell" {
    inline = [
      "touch /tmp/test",
      "echo git_sha: ${local.git_sha}"
    ]
  }
}
