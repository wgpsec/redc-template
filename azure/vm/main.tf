locals {
  password_seed      = replace(uuid(), "-", "")
  generated_password = format("%s_+%s", substr(local.password_seed, 0, 12), substr(local.password_seed, 12, 10))
  instance_password  = var.instance_password != "" ? var.instance_password : local.generated_password

}

resource "azurerm_resource_group" "redc" {
  name     = "redc-resources-1"
  location = "West Europe"
}

resource "azurerm_public_ip" "redc" {
  name                = "test-publicip"
  resource_group_name = azurerm_resource_group.redc.name
  location            = azurerm_resource_group.redc.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "redc" {
  name                = "test-security-group"
  location            = azurerm_resource_group.redc.location
  resource_group_name = azurerm_resource_group.redc.name
  depends_on = [
    azurerm_resource_group.redc,
  ]

  security_rule {
    name                       = "test-security-group-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "redc" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.redc.location
  resource_group_name = azurerm_resource_group.redc.name
  depends_on = [
    azurerm_resource_group.redc,
  ]
}

resource "azurerm_subnet" "redc" {
  name                 = "test-internal"
  resource_group_name  = azurerm_resource_group.redc.name
  virtual_network_name = azurerm_virtual_network.redc.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_resource_group.redc,
    azurerm_virtual_network.redc
  ]
}

resource "azurerm_network_interface" "redc" {
  name                = "test-nic"
  location            = azurerm_resource_group.redc.location
  resource_group_name = azurerm_resource_group.redc.name
  depends_on = [
    azurerm_resource_group.redc,
    azurerm_public_ip.redc,
    azurerm_subnet.redc
  ]

  ip_configuration {
    name                          = "test-internal"
    subnet_id                     = azurerm_subnet.redc.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.redc.id
  }
}

resource "azurerm_linux_virtual_machine" "redc" {
  name                            = "test-machine"
  resource_group_name             = azurerm_resource_group.redc.name
  location                        = azurerm_resource_group.redc.location
  size                            = "Standard_D2a_v4"
  admin_username                  = "redcadmin"
  admin_password                  = local.instance_password
  disable_password_authentication = false
  user_data                       = "IyEvYmluL2Jhc2g="
  network_interface_ids = [
    azurerm_network_interface.redc.id,
  ]
  depends_on = [
    azurerm_resource_group.redc,
    azurerm_network_interface.redc
  ]

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
}
