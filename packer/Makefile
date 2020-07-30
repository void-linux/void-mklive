TEMPLATES=templates/digitalocean-glibc64.json templates/vagrant-glibc64.json

all: $(TEMPLATES)

templates:
	mkdir -p templates

templates/digitalocean-glibc64.json: templates fragments/base-qemu-glibc64.json fragments/provisioner-cloud.json fragments/platform-digitalocean.json
	jq -s 'add' fragments/base-qemu-glibc64.json fragments/provisioner-cloud.json fragments/platform-digitalocean.json > templates/digitalocean-glibc64.json

templates/vagrant-glibc64.json: templates fragments/base-vbox-glibc64.json fragments/platform-vagrant.json
	jq -s 'add' fragments/base-vbox-glibc64.json fragments/platform-vagrant.json > templates/vagrant-glibc64.json
