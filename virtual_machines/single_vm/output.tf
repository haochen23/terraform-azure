output "kmaster0" {
  value = azurerm_linux_virtual_machine.vm0.public_ip_address
}

output "vm_user" {
    value = azurerm_linux_virtual_machine.vm0.admin_username
}