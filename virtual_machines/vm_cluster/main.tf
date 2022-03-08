terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.96.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.localtion
  tags = {
    Environment = var.env_tag
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet1_cidr
}

# Create public IPs
resource "azurerm_public_ip" "pips" {
    for_each                     = toset(var.vm_names)
    name                         = each.value
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg.name 
    allocation_method            = "Dynamic"

    tags = {
        environment = var.env_tag
    }
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg1" {
    name                = "nsg1"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "allow-k8s-api-server"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.env_tag
    }
}

resource "azurerm_network_interface" "nics" {
  for_each            = toset(var.vm_names)
  name                = each.value
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pips[each.key].id
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_associate" {

  for_each = toset(var.vm_names)    
  network_interface_id =  azurerm_network_interface.nics[each.value].id
  network_security_group_id = azurerm_network_security_group.nsg1.id    
}


resource "azurerm_linux_virtual_machine" "vms" {
  for_each            = toset(var.vm_names)
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2_v2"
  admin_username      = "adminuser"
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
        environment = var.env_tag
    }
}

# # file share
# resource "azurerm_storage_account" "storageaccount" {
#   name                     = "aksefkstorageaccount"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_share" "fileshare" {
#   name                 = "aksefkfileshare"
#   storage_account_name = azurerm_storage_account.storageaccount.name
#   quota                = 50
# }
