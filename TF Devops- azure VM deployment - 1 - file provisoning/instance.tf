
resource "azurerm_network_interface" "demo-instance" {
  name                      = "${var.prefix}-instance"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name
  network_security_group_id = azurerm_network_security_group.allow-ssh.id

  ip_configuration {
    name                          = "instance"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-instance.id
  }
}

resource "azurerm_public_ip" "demo-instance" {
    name                         = "instance-public-ip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.demo.name
    allocation_method            = "Dynamic"
    domain_name_label   = "vmtf"
}
#create a data to recicve ip
/*
data "azurerm_public_ip" "demo-instance" {
  name                = azurerm_public_ip.demo-instance.name
  resource_group_name = azurerm_resource_group.demo.name

}

output "vm_ip" {
  value = data.azurerm_public_ip.demo-instance.ip_address
}
*/

# Master
resource "azurerm_virtual_machine" "demo-instance" {
  name                  = "${var.prefix}-Master"
  location              = var.location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [azurerm_network_interface.demo-instance.id]
  vm_size               = "Standard_B1ms"


  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1-Master"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vmtf"
    admin_username = "demo"
    admin_password = "Sbilife@5678"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("mykey.pub")
      path     = "/home/demo/.ssh/authorized_keys"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv index.html /var/www/html/"
    ]

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.demo-instance.fqdn
      user        = "demo"
      private_key  = file("mykey")

    }
 }
}





/*
#------------------------------------------
# Slave1
resource "azurerm_virtual_machine" "demo-instance1" {
  name                  = "${var.prefix}-Slave1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [azurerm_network_interface.demo-instance1.id]
  vm_size               = "Standard_B1ms"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1-S1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "demo-instance"
    admin_username = "demo"
    #admin_password = "..."
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("mykey.pub")
      path     = "/home/demo/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface" "demo-instance1" {
  name                      = "${var.prefix}-instance1"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name
  network_security_group_id = azurerm_network_security_group.allow-ssh.id

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
   # public_ip_address_id          = azurerm_public_ip.demo-instance1.id
  }
}

#resource "azurerm_public_ip" "demo-instance1" {
 #   name                         = "instance1-public-ip"
  #  location                     = var.location
  #  resource_group_name          = azurerm_resource_group.demo.name
   # allocation_method            = "Dynamic"
#}
*/
#----
# Slave2
/*
resource "azurerm_virtual_machine" "demo-instance2" {
  name                  = "${var.prefix}-Slave2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [azurerm_network_interface.demo-instance2.id]
  vm_size               = "Standard_B1ms"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1-S2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "demo-instance"
    admin_username = "demo"
    #admin_password = "..."
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("mykey.pub")
      path     = "/home/demo/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface" "demo-instance2" {
  name                      = "${var.prefix}-instance2"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name
  network_security_group_id = azurerm_network_security_group.allow-ssh.id

  ip_configuration {
    name                          = "instance2"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.demo-instance1.id
  }
}

#resource "azurerm_public_ip" "demo-instance1" {
#  name                         = "instance1-public-ip"
 #   location                     = var.location
  # resource_group_name          = azurerm_resource_group.demo.name
  #  allocation_method            = "Dynamic"
#} 
*/
