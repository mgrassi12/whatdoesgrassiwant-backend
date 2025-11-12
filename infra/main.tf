resource "azurerm_resource_group" "backend" {
  name     = "rg-${var.project_name}-backend"
  location = var.location

  tags = {
    project    = var.project_name
    part       = "backend"
    env        = "prod"
    created_by = "terraform"
  }
}

resource "azurerm_mssql_server" "sql" {
  name                         = "sql-${var.project_name}"
  resource_group_name          = azurerm_resource_group.backend.name
  location                     = azurerm_resource_group.backend.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "wishlist" {
  name      = "wishlistdb"
  server_id = azurerm_mssql_server.sql.id

  max_size_gb = 32
  sku_name    = "GP_S_Gen5_1"        

  min_capacity                = 0.5   
  auto_pause_delay_in_minutes = 60    

  lifecycle {
    prevent_destroy = true   
  }
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name      = "allow-azure-services"
  server_id = azurerm_mssql_server.sql.id

  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

/* 
When this firewall rule is active, I can connect directly to the SQL db from my home network.

resource "azurerm_mssql_firewall_rule" "my_ip" {
  name      = "allow-michael-home"
  server_id = azurerm_mssql_server.sql.id

  start_ip_address = "144.6.40.xx"
  end_ip_address   = "144.6.40.xx"
} 
*/

resource "azurerm_storage_account" "functions" {
  name                     = "st${var.project_name}func"
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version = "TLS1_2"

  tags = {
    project    = var.project_name
    part       = "backend"
    env        = "prod"
    created_by = "terraform"
  }
}

resource "azurerm_service_plan" "functions" {
  name                = "asp-${var.project_name}-func"
  resource_group_name = azurerm_resource_group.backend.name
  location            = azurerm_resource_group.backend.location

  os_type  = "Linux"
  sku_name = "Y1"   # Consumption plan
}

resource "azurerm_linux_function_app" "wishlist_api" {
  name                = "func-${var.project_name}-api"
  resource_group_name = azurerm_resource_group.backend.name
  location            = azurerm_resource_group.backend.location

  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  https_only = true

  site_config {
    application_stack {
      python_version = "3.10"
    }

    cors {
      allowed_origins = [
        "https://www.whatdoesgrassiwant.com",
        "https://delightful-bush-03233451e.3.azurestaticapps.net"
      ]
      support_credentials = false
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"   = "python"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"

    "AzureWebJobsStorage" = azurerm_storage_account.functions.primary_connection_string

    "SQL_CONNECTION_STRING" = "Driver={ODBC Driver 17 for SQL Server};Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.wishlist.name};Uid=${var.sql_admin_login};Pwd=${var.sql_admin_password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  }

  tags = {
    project    = var.project_name
    part       = "backend"
    env        = "prod"
    created_by = "terraform"
  }
}
