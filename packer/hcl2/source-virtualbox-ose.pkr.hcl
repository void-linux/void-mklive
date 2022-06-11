source "virtualbox-iso" "x86_64" {
  guest_os_type = "Linux_64"
  iso_url = "https://repo-default.voidlinux.org/live/20200722/void-live-x86_64-5.7.10_1-20200722.iso"
  iso_checksum = "sha256:d95d40e1eb13a7776b5319a05660792fddd762662eaecee5df6b8feb3aa9b391"
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
