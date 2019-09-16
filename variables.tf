variable "ssh_username" {
  default = "root"
}

variable "ssh_password" {
  default = "passw0rd"
}

variable "bastion_ip_address" {
  default = ""
}

variable "bastion_private_ip" {
  default = ""
}

variable "ssh_private_key" {
  default = ""
}

variable "ansible_playbooks" {
  type = "list"
  default = []
}
variable "ansible_inventory" {
  default = ""
}

variable "dependson" {
  type = "list"
  default = []  
}

variable "bastion_hostname" {
  default = ""
}

variable "master_hostname" {
  type = "list"
  default = []

}
variable "infra_hostname" {
  type = "list"
  default = []
}
variable "worker_hostname" {
  type = "list"
  default = []
}
variable "storage_hostname" {
  type = "list"
  default = []
}

variable "master_private_ip" {
  type = "list"
  default = []
}
variable "infra_private_ip" {
  type = "list"
  default = []
}
variable "worker_private_ip" {
  type = "list"
  default = []
}
variable "storage_private_ip" {
  type = "list"
  default = []
}

variable "storage_count" {
  default = 0
}

variable "triggerson" {
  type = "map"
  default = {}
}

variable "ansible_vars" {
  type = "list"
  default = []
}