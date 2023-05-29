variable "name" {
  description = "shared image name"
  type = string
}

variable "resource_group_name" {
  description = "resource group name"
  type = string
}

variable "gallery_name" {
  description = "image gallery name"
  type = string
}

variable "location" {
  description = "resource group location"
  type = string
}

variable "os_type" {
  description = "OS type"
  type = string
}


variable "image_offer" {
  description = "image offer"
  type = string
}

variable "image_publisher" {
  description = "image publisher"
  type = string
}

variable "image_sku" {
  description = "image sku"
  type = string
}