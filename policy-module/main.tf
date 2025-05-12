terraform {
  required_version = "~> 1.8"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    alz = {
      source  = "azure/alz"
      version = "~> 0.17"
    }
  }
}

data "azapi_client_config" "this" {}

data "alz_architecture" "this" {
  name                     = "alz"
  root_management_group_id = data.azapi_client_config.this.tenant_id
  location                 = var.location
}
