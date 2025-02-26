packer {
  required_plugins {
    azure = {
      version = ">= 3.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

// Variables section
variable "tenant_id" {
  description = "az tenant id"
  type        = string
}
variable "subscription_id" {
  description = "az subscription id"
  type        = string
}
variable "build_key_vault_name" {
  description = "key vault name"
  type        = string
}
variable "build_resource_group_name" {
  description = "build resource group name"
  type        = string
}
variable "image_offer" {
  description = "image offer"
  type        = string
}
variable "image_publisher" {
  description = "image publisher"
  type        = string
}
variable "image_sku" {
  description = "image sku"
  type        = string
}
variable "managed_image_name" {
  description = "managed image name"
  type        = string
}
variable "managed_image_resource_group_name" {
  description = "managed image resource group name"
  type        = string
}
variable "os_type" {
  description = "os type"
  type        = string
}
variable "vm_size" {
  description = "vm size"
  type        = string
}

// Build section
source "azure-arm" "win11-build" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  tenant_id                         = var.tenant_id
  subscription_id                   = var.subscription_id
  build_key_vault_name              = var.build_key_vault_name
  build_resource_group_name         = var.build_resource_group_name
  communicator                      = "winrm"
  image_offer                       = var.image_offer
  image_publisher                   = var.image_publisher
  image_sku                         = var.image_sku
  managed_image_name                = var.managed_image_name
  managed_image_resource_group_name = var.managed_image_resource_group_name
  os_type                           = var.os_type
  vm_size                           = var.vm_size
  winrm_use_ssl                     = true
  winrm_insecure                    = false
  winrm_timeout                     = "5m"
  winrm_username                    = "packer"

  # Use user-assigned managed identity
  use_managed_identity = false  # Disabling system-assigned managed identity
  client_id = "<your-user-assigned-managed-identity-client-id>"  # Specify the client ID of your user-assigned managed identity
}

build {
  sources = ["win11-build"]

  provisioner "powershell" {
    inline = [
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }"
    ]
  }

  provisioner "powershell" {
    inline = [
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
