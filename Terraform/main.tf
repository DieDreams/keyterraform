
provider "azurerm" {
    features {}
}

## Declare Variables

variable "resource_group_name" {
  default = "test1-res-gr"
}

variable "location" {
  default = "East US"
}

variable "VAULT_URI" {}

## Generate Random String

resource "random_string" "vm_password" {
  length      = 14
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

# ## Create the secret
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_key_vault" "example" {
  name                       = "examplekeyvault"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}
# resource "azurerm_key_vault_secret" "vm_secret" {
#   name      = "vm-secret"
#   value     = "${random_string.vm_password.result}"
#   key_vault_id  = "https://test1-res-key-vault.vault.azure.net/"

#   tags      = "${var.resource_group_name}"
# }

# ## Print secret data to console

# output "vm_password_result" {
#   value = "${azurerm_key_vault_secret.vm_secret.value}"
# }

# ## Create the VM
# ## The below is not a complete code and only used to demonstrate the password consumption concept

# resource "azurerm_virtual_machine" "vm" {
#   name                  = "${var.resource_group_name}-myvm"
#   location              = "${var.location}"
#   resource_group_name   = "${var.resource_group_name}"

#   ## Removed additional config for readability
  
#   os_profile {
#     computer_name  = "${var.resource_group_name}-myvm"
#     admin_username = "admin"
#     admin_password = "${azurerm_key_vault_secret.vm_secret.value}" # Use the secret created earlier
#   }
# }