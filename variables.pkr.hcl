variable "tenant_id" {
  description = "az tenant id"
  type = string
  default = "cceca895-6c09-46b8-b016-42f2100ebadf"
}
variable "client_id" {
  description = "app reg client id"
  type = string
}
variable "client_secret" {
  description = "app reg client secret"
  type = string
}
variable "subscription_id" {
  description = "az subscription id"
  type = string
  default = "0e4cfcad-ab43-48e2-9e53-2b0a2624a8c7"
}
variable "build_resource_group_name" {
  description = "build resource group name"
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
variable "managed_image_name" {
  description = "managed image name"
  type = string
}
variable "managed_image_resource_group_name" {
  description = "managed image resource group name"
  type = string
}
variable "os_type" {
  description = "os type"
  type = string
}
variable "vm_size" {
  description = "vm size"
  type = string
  default = "Standard_B2ms"
}