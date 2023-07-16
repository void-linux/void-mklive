source "qemu" "x86_64" {
  accelerator = "kvm"
  boot_wait = "5s"
  disk_interface = "virtio"
  disk_size = "2000M"
  format = "qcow2"
  http_directory = "http"
  iso_checksum = "sha256:5507fe41f54719e78db7b0f9c685f85b063616d913b14f815dd481b5ea66e397"
  iso_url = "https://repo-default.voidlinux.org/live/20221001/void-live-x86_64-20221001-base.iso"
  ssh_password = "void"
  ssh_timeout = "20m"
  ssh_username = "void"
}
