variable "resource_group_name" {
  default = "vmtestrg"
}

variable "location" {
    default = "eastus"
}
variable "vnet_name" {
    default = "vm-test-vnet"
}

variable "vnet_cidr" {
    default = ["10.240.0.0/16"]
}

variable "subnet1_cidr" {
    default = ["10.240.0.0/24"]
}

variable "env_tag" {
  default = "test"
}

variable "vm_name" {
    default = "vm0"
}

variable "vm_sku" {
    default = "Standard_D2_v2"
}

variable "admin_username" {
    default = "adminuser"
}