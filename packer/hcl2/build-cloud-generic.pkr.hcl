build {
  name = "cloud-generic-x86_64"

  source "source.qemu.x86_64" {
    boot_command = [
      "<tab><wait>",
      "auto autourl=http://{{.HTTPIP}}:{{.HTTPPort}}/x86_64.cfg",
      "<enter>"
    ]
    vm_name = "voidlinux-x86_64"
    output_directory = "cloud-generic-x86_64"
  }

  provisioner "shell" {
    script = "scripts/cloud.sh"
    execute_command = "echo 'void' | {{.Vars}} sudo -E -S bash '{{.Path}}'"
  }
}

build {
  name = "cloud-generic-x86_64-musl"

  source "source.qemu.x86_64" {
    boot_command = [
      "<tab><wait>",
      "auto autourl=http://{{.HTTPIP}}:{{.HTTPPort}}/x86_64-musl.cfg",
      "<enter>"
    ]
    vm_name = "voidlinux-x86_64-musl"
    output_directory = "cloud-generic-x86_64-musl"
  }

  provisioner "shell" {
    script = "scripts/cloud.sh"
    execute_command = "echo 'void' | {{.Vars}} sudo -E -S bash '{{.Path}}'"
  }
}
