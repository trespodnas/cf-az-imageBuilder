terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.58.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_shared_image" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  gallery_name        = var.gallery_name
  location            = var.location
  os_type             = var.os_type
  identifier {
    offer     = var.image_offer
    publisher = var.image_publisher
    sku       = var.image_sku
  }
}