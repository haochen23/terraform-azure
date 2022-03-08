variable "resource_group_name" {
  default = "kubernetes"
}

variable "location" {
  default = "eastus"
}

variable "vnet_name" {
    default = "kubernetes-vnet"
}

variable "vnet_cidr" {
    default = ["10.0.0.0/16"]
}

variable "subnet1_cidr" {
    default = ["10.0.0.0/24"]
}

variable "env_tag" {
  default = "test"
}

# variable "pip_names" {
#   description = "Name of Pips"
#   type = list(string)
#   default = ["kmaster0-pip", "kworker0-pip", "kworker1-pip", "kworker2-pip"]
# }

# variable "nic_names" {
#   description = "Name of NICs"
#   type = list(string)
#   default = ["kmaster0-nic", "kworker0-nic", "kworker1-nic", "kworker2-nic"]
# }

variable "vm_names" {
  description = "Name of VMs"
  type = list(string)
  default = ["kmaster0", "kworker0", "kworker1", "kworker2"]
}