# Specify the required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.9.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "145d19dc-aee1-4acc-8725-070592df466f"  # Replace with your actual subscription ID
  tenant_id       = "5d0aa6ea-6620-4863-9e21-9ecb140222bc"  # Replace with your actual tenant ID
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "LHRV-resources"
  location = "northeurope"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "LHRV-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a Subnet
resource "azurerm_subnet" "example" {
  name                 = "LHRVsubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "LRVH-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Define the IP Configuration block
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                = "LHRV-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  vm_size             = "Standard_B1s"

  storage_os_disk {
    name              = "LHRV-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    os_type           = "Linux"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
     sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "LHRV-vm"
    admin_username = "varsha"
    admin_password = "@password123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
