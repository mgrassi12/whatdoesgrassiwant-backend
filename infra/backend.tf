terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstategrassi"
    container_name       = "tfstate"
    key                  = "wishlist-backend.tfstate"
  }
}