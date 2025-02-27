variable "MIRROR" {
  default = "https://repo-ci.voidlinux.org/"
}

target "docker-metadata-action" {}

target "_common" {
  inherits = ["docker-metadata-action"]
  dockerfile = "container/Containerfile"
  cache-to = ["type=local,dest=/tmp/buildx-cache"]
  cache-from = ["type=local,src=/tmp/buildx-cache"]
  args = {
    "MIRROR" = "${MIRROR}"
  }
}

target "void-mklive" {
  inherits = ["_common"]
  platforms = ["linux/amd64", "linux/arm64"]
}
