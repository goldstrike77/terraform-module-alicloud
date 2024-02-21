# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。

locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources : {
      resource_group_name = lookup(s.resource_manager_resource_group, "resource_group_name", s.resource_manager_resource_group.display_name)
      display_name        = s.resource_manager_resource_group.display_name
    } if can(s.resource_manager_resource_group)
  ])
  db_instance_flat = flatten([
    for s in var.resources : [
      for t in s.db : [
        for u in t.instance : {
          display_name                   = s.resource_manager_resource_group.display_name
          vpc_name                       = t.vpc
          vswitch_name                   = t.vswitch
          security_group                 = t.security_group
          engine                         = lookup(u, "engine", "MySQL")
          engine_version                 = lookup(u, "engine_version", "8.0")
          instance_type                  = lookup(u, "instance_type", "mysql.n1e.small.1")
          instance_storage               = lookup(u, "instance_storage", "20")
          db_instance_storage_type       = lookup(u, "db_instance_storage_type", "cloud_essd")
          db_time_zone                   = lookup(u, "db_time_zone", "+8:00")
          sql_collector_status           = lookup(u, "sql_collector_status", "Disabled")
          sql_collector_config_value     = lookup(u, "sql_collector_config_value", "30")
          instance_name                  = u.name
          connection_string_prefix       = lookup(u, "connection_string_prefix", u.name)
          port                           = lookup(u, "port", "3306")
          instance_charge_type           = lookup(u, "instance_charge_type", "Postpaid")
          period                         = lookup(u, "period", null)
          monitoring_period              = lookup(u, "monitoring_period", "300")
          auto_renew                     = lookup(u, "auto_renew", false)
          auto_renew_period              = lookup(u, "auto_renew_period", 1)
          zone_id                        = lookup(u, "zone_id", null)
          private_ip_address             = lookup(u, "private_ip_address", null)
          security_ips                   = lookup(u, "security_ips", ["127.0.0.1"])
          db_instance_ip_array_name      = lookup(u, "db_instance_ip_array_name", "Default")
          db_instance_ip_array_attribute = lookup(u, "db_instance_ip_array_attribute", null)
          security_ip_type               = lookup(u, "security_ip_type", null)
          db_is_ignore_case              = lookup(u, "db_is_ignore_case", true)
          whitelist_network_type         = lookup(u, "whitelist_network_type", "MIX")
          modify_mode                    = lookup(u, "modify_mode", "Cover")
          security_ip_mode               = lookup(u, "security_ip_mode", "normal")
          fresh_white_list_readins       = lookup(u, "fresh_white_list_readins", null)
          parameters                     = lookup(u, "parameters", [])
          force_restart                  = lookup(u, "force_restart", false)
          tags                           = lookup(u, "tags", {})
          maintain_time                  = lookup(u, "maintain_time", "16:00Z-20:00Z")
          auto_upgrade_minor_version     = lookup(u, "auto_upgrade_minor_version", "Manual")
          upgrade_time                   = lookup(u, "upgrade_time", "MaintainTime")
          switch_time                    = lookup(u, "switch_time", null)
          target_minor_version           = lookup(u, "target_minor_version", null)
          zone_id_slave_a                = lookup(u, "zone_id_slave_a", null)
          ssl_action                     = lookup(u, "ssl_action", "Open")
          ssl_connection_string          = lookup(u, "ssl_connection_string", null)
          tde_status                     = lookup(u, "tde_status", null)
          encryption_key                 = lookup(u, "encryption_key", null)
          ca_type                        = lookup(u, "ca_type", "aliyun")
          server_cert                    = lookup(u, "server_cert", null)
          server_key                     = lookup(u, "server_key", null)
          client_ca_enabled              = lookup(u, "client_ca_enabled", "0")
          client_ca_cert                 = lookup(u, "client_ca_cert", null)
          client_crl_enabled             = lookup(u, "client_crl_enabled", "0")
          client_cert_revocation_list    = lookup(u, "client_cert_revocation_list", null)
          acl                            = lookup(u, "acl", null)
          replication_acl                = lookup(u, "replication_acl", null)
          ha_config                      = lookup(u, "ha_config", "Auto")
          manual_ha_time                 = lookup(u, "manual_ha_time", null)
          released_keep_policy           = lookup(u, "released_keep_policy", "All")
          storage_auto_scale             = lookup(u, "storage_auto_scale", "Disable")
          storage_threshold              = lookup(u, "storage_threshold", null)
          storage_upper_bound            = lookup(u, "storage_upper_bound", null)
          deletion_protection            = lookup(u, "deletion_protection", false)
          tcp_connection_type            = lookup(u, "tcp_connection_type", "LONG")
          category                       = lookup(u, "category", "Basic")
          pg_hba_conf                    = lookup(u, "pg_hba_conf", {})
          babelfish_port                 = lookup(u, "babelfish_port", null)
          babelfish_config               = lookup(u, "babelfish_config", {})
          effective_time                 = lookup(u, "effective_time", "MaintainTime")
          serverless_config              = lookup(u, "serverless_config", {})
          role_arn                       = lookup(u, "role_arn", null)
          direction                      = lookup(u, "direction", null)
          node_id                        = lookup(u, "node_id", null)
          force                          = lookup(u, "force", null)
        }
      ] if can(t.instance)
    ] if can(s.db)
  ])
}
