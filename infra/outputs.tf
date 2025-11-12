output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_connection_string" {
  description = "Connection string you can use from tools / later from Functions"
  value       = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.wishlist.name};Persist Security Info=False;User ID=${var.sql_admin_login};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

output "function_app_name" {
  value       = azurerm_linux_function_app.wishlist_api.name
  description = "Name of the wishlist API Function App"
}

output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.wishlist_api.default_hostname
  description = "Default hostname for the Function App"
}
