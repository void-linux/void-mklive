build {
  name = "vagrant-virtualbox-x86_64"

  source "source.virtualbox-iso.x86_64" {
    boot_command = [
      "<tab><wait>",
      "auto autourl=http://{{.HTTPIP}}:{{.HTTPPort}}/x86_64.cfg",
      "<enter>"
    ]
    vm_name = "voidlinux-x86_64"
    output_directory = "vagrant-virtualbox-x86_64"
  }

  provisioner "shell" {
    script = "scripts/vagrant.sh"
    execute_command = "echo 'void' | {{.Vars}} sudo -E -S bash '{{.Path}}'"
  }

  post-processor "vagrant" {
    output = "vagrant-virtualbox-x86_64.box"
  }
}

build {
  name = "vagrant-virtualbox-x86_64-musl"

  source "source.virtualbox-iso.x86_64" {
    boot_command = [
      "<tab><wait>",
      "auto autourl=http://{{.HTTPIP}}:{{.HTTPPort}}/x86_64-musl.cfg",
      "<enter>"
    ]
    vm_name = "voidlinux-x86_64-musl"
    output_directory = "vagrant-virtualbox-x86_64-musl"
  }

  provisioner "shell" {
    script = "scripts/vagrant.sh"
    execute_command = "echo 'void' | {{.Vars}} sudo -E -S bash '{{.Path}}'"
  }

  post-processor "vagrant" {
    output = "vagrant-virtualbox-x86_64-musl.box"
  }
}
