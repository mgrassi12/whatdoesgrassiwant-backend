terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "6d770328-989f-421b-b2c2-2ed7b0d484e5"
  tenant_id       = "3c15dc7a-3883-4bbb-b5a6-41bdbb8b7900"
}
