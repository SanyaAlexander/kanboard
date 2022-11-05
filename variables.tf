variable "location" {
    type = string
    description = "Location for the deployment"
    default = "East US"
}

variable "rgname" {
    type = string
    description = "Resource group name"
    default = "TerraformRG"
}

variable "webapp_plan_name" {
    type = string
    description = "Webapp plan name"
    default = "KanboardTerraformPlan"
}

variable "webapp_name" {
    type = string
    description = "Webapp name"
    default = "KanboardTerraform"
}

variable "vnet_name" {
    type = string
    description = "Virtual network name"
    default = "kanboard_vnet"
}

variable "db_subnet_name" {
    type = string
    description = "Database subnet name"
    default = "db-subnet"
}

variable "app_subnet_name" {
    type = string
    description = "Webapp subnet name"
    default = "app-subnet"
}

variable "mysql_server_name" {
    type = string
    description = "Mysql database server name"
    default = "terraform-mysql-kanboard"
}

variable "db_admin_login" {
    type = string
    description = "Administrator login for Database"
    default = "myadmin"
}

variable "db_admin_password" {
    type = string
    description = "Administrator password for Database"
    default = "592C6F4E44#"
}

variable "private_dns_zone_name" {
    type = string
    description = "Private DNS zone name"
    default = "kanboardterraform.mysql.database.azure.com"
}

variable "virtual_network_link_name" {
    type = string
    description = "Virtual network link name"
    default = "kanboardVnetZone.com"
}