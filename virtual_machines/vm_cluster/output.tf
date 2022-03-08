output "pips" {
  value = [ 
    for vm in azurerm_linux_virtual_machine.vms : vm.public_ip_address
  ]
    # value = azurerm_linux_virtual_machine.vms
    # sensitive = true
}

output "vm_user" {
    value = [
        for vm in azurerm_linux_virtual_machine.vms : vm.admin_username
    ]
}
