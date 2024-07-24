source "qemu" "x86_64" {
  accelerator = "kvm"
  boot_wait = "5s"
  disk_interface = "virtio"
  disk_size = "2000M"
  format = "qcow2"
  http_directory = "http"
  iso_url = "https://repo-default.voidlinux.org/live/20240314/void-live-x86_64-20240314-base.iso"
  iso_checksum = "sha256:c1a3c0aff363057132f8dab80287396df8a8b4d7cd7f7d8d3f0e2c3ee9e5be7d"
  ssh_password = "void"
  ssh_timeout = "20m"
  ssh_username = "void"
}
