terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "b5798305-3a2b-40a8-ab96-90e8c471ddeb"
}

resource "azurerm_resource_group" "dop_rg" {
  name     = "dop-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "dop_vn" {
  name                = "dop-vn"
  resource_group_name = azurerm_resource_group.dop_rg.name
  location            = azurerm_resource_group.dop_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "dop_subnet" {
  count                = length(var.vms_config)
  name                 = "dop-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.dop_rg.name
  virtual_network_name = azurerm_virtual_network.dop_vn.name
  address_prefixes     = ["10.0.${count.index + 1}.0/24"]
}

resource "azurerm_network_security_group" "dop_nsg" {
  name                = "dop-nsg"
  location            = azurerm_resource_group.dop_rg.location
  resource_group_name = azurerm_resource_group.dop_rg.name
  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_security_rule" "dop_dev_rule" {
  name                        = "dop-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = var.allowed_ports
  source_address_prefix       = var.my_public_ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dop_rg.name
  network_security_group_name = azurerm_network_security_group.dop_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "dop_sga" {
  for_each                  = { for idx, subnet in azurerm_subnet.dop_subnet : idx => subnet.id }
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.dop_nsg.id
}

resource "azurerm_public_ip" "dop_ip" {
  count               = length(var.vms_config)
  name                = "dop-${var.vms_config[count.index].name}-ip"
  resource_group_name = azurerm_resource_group.dop_rg.name
  location            = azurerm_resource_group.dop_rg.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "dop_nic" {
  count               = length(var.vms_config)
  name                = "dop-${var.vms_config[count.index].name}-nic"
  location            = azurerm_resource_group.dop_rg.location
  resource_group_name = azurerm_resource_group.dop_rg.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dop_ip[count.index].id
    subnet_id                     = azurerm_subnet.dop_subnet[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "dop_vms" {
  count               = length(var.vms_config)
  name                = var.vms_config[count.index].name
  resource_group_name = azurerm_resource_group.dop_rg.name
  location            = azurerm_resource_group.dop_rg.location
  size                = var.vms_config[count.index].vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.dop_nic[count.index].id
  ]

  custom_data = filebase64(var.vms_config[count.index].template_file)

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.vms_config[count.index].ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}

data "azurerm_public_ip" "dop_ip_data" {
  count               = length(var.vms_config)
  name                = azurerm_public_ip.dop_ip[count.index].name
  resource_group_name = azurerm_resource_group.dop_rg.name
}

output "vm_ip_addresses" {
  value = [
    for i in range(length(var.vms_config)) : {
      hostname  = azurerm_linux_virtual_machine.dop_vms[i].name
      public_ip = data.azurerm_public_ip.dop_ip_data[i].ip_address
    }
  ]
}