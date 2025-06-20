resource "azurerm_postgresql_flexible_server" "postgresql_server" {
  name                = var.postgres_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  administrator_login    = var.administrator_username
  administrator_password = var.administrator_password
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  storage_tier           = var.storage_tier
  version                = var.postgresql_version
  zone = null

  lifecycle {
    ignore_changes = [
      zone
    ]
  }
}

# Because Function Apps with consumption plan is used, private endpoint is not available so all Azure Services must be allowed for the Function Apps to communicate with the database.
resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_allow_azure_services" {
  count            = var.fw_allow_azure_services ? 1 : 0
  name             = "azure-services-fw"
  server_id        = azurerm_postgresql_flexible_server.postgresql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_authorized_ips" {
  count            = length(var.authorized_ips)
  name             = "authorized-ip-${count.index}"
  server_id        = azurerm_postgresql_flexible_server.postgresql_server.id
  start_ip_address = var.authorized_ips[count.index]
  end_ip_address   = var.authorized_ips[count.index]
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  count     = length(var.databases)
  name      = var.databases[count.index]
  server_id = azurerm_postgresql_flexible_server.postgresql_server.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}