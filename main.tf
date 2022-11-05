terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.28.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_virtual_network" "kanboard_vnet" {
  name                = var.vnet_name
  address_space       = ["10.1.0.0/27"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "database_subnet" {
  name                 = var.db_subnet_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.kanboard_vnet.name
  address_prefixes     = ["10.1.0.0/28"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "kanboard_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = var.virtual_network_link_name
  private_dns_zone_name = azurerm_private_dns_zone.kanboard_dns.name
  virtual_network_id    = azurerm_virtual_network.kanboard_vnet.id
  resource_group_name   = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "app_subnet" {
  name                 = var.app_subnet_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.kanboard_vnet.name
  address_prefixes     = ["10.1.0.16/28"]

  delegation {
    name = "webapp"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                   = var.mysql_server_name
  resource_group_name    = azurerm_resource_group.resource_group.name
  location               = azurerm_resource_group.resource_group.location
  administrator_login    = var.db_admin_login
  administrator_password = var.db_admin_password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.database_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.kanboard_dns.id
  sku_name               = "B_Standard_B1s"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_link]
  storage {
    size_gb = 20
    iops = 360
  }
}

resource "azurerm_mysql_flexible_server_configuration" "secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
  value               = "OFF"
}

resource "azurerm_service_plan" "webapp_plan" {
  name                = var.webapp_plan_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "kanboard_terraform" {
  name                = var.webapp_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_service_plan.webapp_plan.location
  service_plan_id     = azurerm_service_plan.webapp_plan.id

  site_config {
    application_stack {
      php_version = "7.4"
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet" {
  app_service_id = azurerm_linux_web_app.kanboard_terraform.id
  subnet_id      = azurerm_subnet.app_subnet.id
}