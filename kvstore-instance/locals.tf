# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。

locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources : {
      resource_group_name = lookup(s.resource_manager_resource_group, "resource_group_name", s.resource_manager_resource_group.display_name)
      display_name        = s.resource_manager_resource_group.display_name
    } if can(s.resource_manager_resource_group)
  ])
  kvstore_instance_flat = flatten([
    for s in var.resources : [
      for t in s.kvstore : [
        for u in t.instance : {
          display_name                = s.resource_manager_resource_group.display_name
          vpc_name                    = t.vpc
          db_instance_name            = u.name
          password                    = lookup(u, "password", null)
          kms_encrypted_password      = lookup(t, "kms_encrypted_password", null)
          kms_encryption_context      = lookup(t, "kms_encryption_context", null)
          instance_class              = lookup(t, "instance_class", "redis.shard.micro.ce")
          capacity                    = lookup(t, "capacity", null)
          zone_id                     = lookup(t, "zone_id", null)
          secondary_zone_id           = lookup(t, "secondary_zone_id", null)
          payment_type                = lookup(t, "payment_type", "PostPaid")
          period                      = lookup(t, "period", null)
          auto_renew                  = lookup(t, "auto_renew", false)
          auto_renew_period           = lookup(t, "auto_renew_period", null)
          instance_type               = title(lookup(t, "instance_type", "Redis"))
          vswitch_name                = lookup(t, "vswitch", null)
          engine_version              = lookup(t, "engine_version", "7.0")
          tags                        = lookup(t, "tags", {})
          security_ips                = lookup(t, "security_ips", ["127.0.0.1"])
          security_ip_group_attribute = lookup(t, "security_ip_group_attribute", null)
          security_ip_group_name      = lookup(t, "security_ip_group_name", null)
          security_group              = lookup(t, "security_group", null)
          private_ip                  = lookup(t, "private_ip", null)
          backup_id                   = lookup(t, "backup_id", null)
          srcdb_instance_id           = lookup(t, "srcdb_instance_id", null)
          restore_time                = lookup(t, "restore_time", null)
          vpc_auth_mode               = title(lookup(t, "vpc_auth_mode", "Open"))
          config                      = lookup(t, "config", null)
          maintain_start_time         = lookup(t, "maintain_start_time", "16:00Z")
          maintain_end_time           = lookup(t, "maintain_end_time", "20:00Z")
          effective_time              = lookup(t, "effective_time", null)
          order_type                  = lookup(t, "order_type", "UPGRADE")
          ssl_enable                  = title(lookup(t, "ssl_enable", "Disable"))
          force_upgrade               = lookup(t, "force_upgrade", true)
          dedicated_host_group_id     = lookup(t, "dedicated_host_group_id", null)
          coupon_no                   = lookup(t, "coupon_no", null)
          business_info               = lookup(t, "business_info", null)
          auto_use_coupon             = lookup(t, "auto_use_coupon", false)
          instance_release_protection = lookup(t, "instance_release_protection", false)
          global_instance_id          = lookup(t, "global_instance_id", null)
          global_instance             = lookup(t, "global_instance", false)
          backup_period               = lookup(t, "backup_period", ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
          backup_time                 = lookup(t, "backup_time", "20:00Z-22:00Z")
          enable_backup_log           = lookup(t, "enable_backup_log", 0)
          private_connection_prefix   = lookup(t, "private_connection_prefix", u.name)
          private_connection_port     = lookup(t, "private_connection_port", 6379)
          dry_run                     = lookup(t, "dry_run", false)
          tde_status                  = title(lookup(t, "tde_status", "Enabled"))
          encryption_name             = lookup(t, "encryption_name", null)
          encryption_key              = lookup(t, "encryption_key", null)
          role_arn                    = lookup(t, "role_arn", null)
          shard_count                 = lookup(t, "shard_count", null)
          connection_string_prefix    = lookup(t, "connection_string_prefix", null)
          port                        = lookup(t, "port", "6379")
          db_audit                    = lookup(t, "db_audit", true)
          retention                   = lookup(t, "retention", 180)
        }
      ] if can(t.instance)
    ] if can(s.kvstore)
  ])
  kvstore_account_flat = flatten([
    for s in var.resources : [
      for t in s.kvstore : [
        for u in t.instance : [
          for v in u.account : {
            db_instance_name       = u.name
            account_name           = v.name
            account_password       = lookup(v, "password", null)
            description            = lookup(v, "description", null)
            kms_encrypted_password = lookup(v, "kms_encrypted_password", null)
            kms_encryption_context = lookup(v, "kms_encryption_context", null)
            account_type           = "Normal"
            account_privilege      = lookup(v, "account_privilege", "RoleReadOnly")
          }
        ] if can(u.account)
      ] if can(t.instance)
    ] if can(s.kvstore)
  ])
}
