source "qemu" "x86_64" {
  accelerator = "kvm"
  boot_wait = "5s"
  disk_interface = "virtio"
  disk_size = "2000M"
  format = "qcow2"
  http_directory = "http"
  iso_checksum = "sha256:d95d40e1eb13a7776b5319a05660792fddd762662eaecee5df6b8feb3aa9b391"
  iso_url = "https://repo-default.voidlinux.org/live/20200722/void-live-x86_64-5.7.10_1-20200722.iso"
  ssh_password = "void"
  ssh_timeout = "20m"
  ssh_username = "void"
}
