resource "null_resource" "dependency" {
  triggers = {
    all_dependencies = "${join(",", var.dependson)}"
  }
}

locals {
  ansible_inventory = "/tmp/${uuid()}_ansible.cfg"
}

data "template_file" "ansible_inventory" {
  template = <<EOF
[ansible:children]
bastion
masters
nodes

[ansible:vars]
ansible_ssh_user=${var.ssh_username}
${var.ssh_username == "root" ? "" : "ansible_become=true"}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=60s'
${join("\n", formatlist("%v", var.ansible_vars))}

[bastion]
${join("\n", formatlist("%v ansible_host=%v", var.bastion_hostname, var.bastion_private_ip))}

[masters]
${join("\n", formatlist("%v ansible_host=%v", var.master_hostname, var.master_private_ip))}

[nodes]
${join("\n", formatlist("%v ansible_host=%v", var.master_hostname, var.master_private_ip))}
${join("\n", formatlist("%v ansible_host=%v", var.infra_hostname, var.infra_private_ip))}
${join("\n", formatlist("%v ansible_host=%v", var.worker_hostname, var.worker_private_ip))}
${var.storage_count > 0 ? join("\n", formatlist("%v ansible_host=%v", var.storage_hostname, var.storage_private_ip)) : "" }
EOF
}


resource "null_resource" "copy_ansible_inventory" {
  triggers = {
    timestamp = "${timestamp()}"
  }
  connection {
    type        = "ssh"
    host        = "${var.bastion_ip_address}"
    user        = "${var.ssh_username}"
    private_key = "${var.ssh_private_key}"
    password    = "${var.ssh_password}"
  }

  provisioner "file" {
    content = "${var.ansible_inventory == "" ? data.template_file.ansible_inventory.rendered : var.ansible_inventory}"
    destination = "${local.ansible_inventory}"
  }

  depends_on = [
    "data.template_file.ansible_inventory"
  ]
}

resource "null_resource" "run_playbook" {
  count = "${length(var.ansible_playbooks)}"
  
  triggers = "${var.triggerson}"
  connection {
    type        = "ssh"
    host        = "${var.bastion_ip_address}"
    user        = "${var.ssh_username}"
    private_key = "${var.ssh_private_key}"
    password    = "${var.ssh_password}"
  }
  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "ansible-playbook -i ${local.ansible_inventory} ${element(var.ansible_playbooks, count.index)}",
      "# rm ${local.ansible_inventory}"
    ]
  }
  depends_on = [
    "null_resource.dependency",
    "data.template_file.ansible_inventory",
    "null_resource.copy_ansible_inventory",
  ]
}