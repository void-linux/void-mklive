source "virtualbox-iso" "x86_64" {
  guest_os_type = "Linux_64"
  iso_url = "https://repo-default.voidlinux.org/live/20240314/void-live-x86_64-20240314-base.iso"
  iso_checksum = "sha256:c1a3c0aff363057132f8dab80287396df8a8b4d7cd7f7d8d3f0e2c3ee9e5be7d"
  ssh_username = "void"
  ssh_password = "void"
  http_directory = "http"
  ssh_timeout = "20m"
  guest_additions_mode = "disable"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nictype1", "virtio"],
  ]

  boot_wait = "5s"
}
