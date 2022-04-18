// This interface is for appvm1
resource "azurerm_network_interface" "app_interface" {
  count = 2
  name                = format("app-interface%s",(count.index)+1)
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_subnet.SubnetA
  ]
}

# // This interface is for appvm2
# resource "azurerm_network_interface" "app_interface2" {
#   name                = "app-interface2"
#   location            = azurerm_resource_group.app_grp.location
#   resource_group_name = azurerm_resource_group.app_grp.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.SubnetA.id
#     private_ip_address_allocation = "Dynamic"    
#   }

#   depends_on = [
#     azurerm_virtual_network.app_network,
#     azurerm_subnet.SubnetA
#   ]
# }

// This is the resource for appvm1
resource "azurerm_windows_virtual_machine" "app_vm" {
  count               = 2
  name                = format("%s%s",var.vm_details.vm_names,(count.index)+1)
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  size                = "Standard_D2s_v3"
  admin_username      = "demousr"
  admin_password      = "Azure@123"  
  network_interface_ids = [
    azurerm_network_interface.app_interface[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface
  ]
}

// This is the resource for appvm2
# resource "azurerm_windows_virtual_machine" "app_vm2" {
#   name                = "appvm2"
#   resource_group_name = azurerm_resource_group.app_grp.name
#   location            = azurerm_resource_group.app_grp.location
#   size                = "Standard_D2s_v3"
#   admin_username      = "demousr"
#   admin_password      = "Azure@123"  
#   network_interface_ids = [
#     azurerm_network_interface.app_interface2.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }

#   depends_on = [
#     azurerm_network_interface.app_interface2
#   ]
# }



// This is the extension for appvm1
resource "azurerm_virtual_machine_extension" "vm_extension1" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm[0].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config_video
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data/IIS_Config_video.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_video.ps1"     
    }
SETTINGS
}


// This is the extension for appvm2
resource "azurerm_virtual_machine_extension" "vm_extension2" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm[1].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config_image
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data/IIS_Config_image.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_image.ps1"     
    }
SETTINGS
}


resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

# We are creating a rule to allow traffic on port 80
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}