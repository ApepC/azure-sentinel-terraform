# ── Module: Storage Account ──────────────────────────────────

data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "main" {
  name                            = "st${replace(var.prefix, "-", "")}${var.suffix}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = var.environment == "prod" ? "GRS" : "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = var.tags

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [
      var.frontend_subnet_id,
      var.data_subnet_id,
    ]
  }

  blob_properties {
    versioning_enabled = var.environment == "prod"
    delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }
    container_delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }
  }
}

# ── Diagnostic Settings → Log Analytics ──────────────────────
resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = "diag-storage-${var.prefix}"
  target_resource_id         = "${azurerm_storage_account.main.id}/blobServices/default"
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log { category = "StorageRead"   }
  enabled_log { category = "StorageWrite"  }
  enabled_log { category = "StorageDelete" }

  metric {
    category = "Transaction"
    enabled  = true
  }
}
