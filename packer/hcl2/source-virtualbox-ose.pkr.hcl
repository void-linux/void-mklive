source "virtualbox-iso" "x86_64" {
  guest_os_type = "Linux_64"
  iso_url = "https://repo-default.voidlinux.org/live/20221001/void-live-x86_64-20221001-base.iso"
  iso_checksum = "sha256:5507fe41f54719e78db7b0f9c685f85b063616d913b14f815dd481b5ea66e397"
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
