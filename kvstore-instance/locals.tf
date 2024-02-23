# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。

locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources : {
      resource_group_name = lookup(s.resource_manager_resource_group, "resource_group_name", s.resource_manager_resource_group.display_name)
      display_name        = s.resource_manager_resource_group.display_name
    } if can(s.resource_manager_resource_group)
  ])
  security_group_flat = flatten([
    for s in var.resources : [
      for t in s.kvstore : [
        for u in t.security_group : {
          vpc_name       = t.vpc
          security_group = u

        }
      ] if can(t.security_group)
    ] if can(s.kvstore)
  ])
  kvstore_instance_flat = flatten([
    for s in var.resources : [
      for t in s.kvstore : [
        for u in t.instance : {
          display_name                = s.resource_manager_resource_group.display_name
          vpc_name                    = t.vpc
          vswitch_name                = lookup(t, "vswitch", [])
          security_group              = lookup(t, "security_group", [])
          db_instance_name            = u.name
          password                    = lookup(u, "password", null)
          kms_encrypted_password      = lookup(u, "kms_encrypted_password", null)
          kms_encryption_context      = lookup(u, "kms_encryption_context", null)
          instance_class              = lookup(u, "instance_class", "redis.shard.micro.ce")
          capacity                    = lookup(u, "capacity", null)
          zone_id                     = lookup(u, "zone_id", null)
          secondary_zone_id           = lookup(u, "secondary_zone_id", null)
          payment_type                = lookup(u, "payment_type", "PostPaid")
          period                      = lookup(u, "period", null)
          auto_renew                  = lookup(u, "auto_renew", false)
          auto_renew_period           = lookup(u, "auto_renew_period", null)
          instance_type               = title(lookup(u, "instance_type", "Redis"))
          engine_version              = lookup(u, "engine_version", "7.0")
          tags                        = lookup(u, "tags", {})
          security_ips                = lookup(u, "security_ips", ["127.0.0.1"])
          security_ip_group_attribute = lookup(u, "security_ip_group_attribute", null)
          security_ip_group_name      = lookup(u, "security_ip_group_name", null)
          private_ip                  = lookup(u, "private_ip", null)
          backup_id                   = lookup(u, "backup_id", null)
          srcdb_instance_id           = lookup(u, "srcdb_instance_id", null)
          restore_time                = lookup(u, "restore_time", null)
          vpc_auth_mode               = title(lookup(u, "vpc_auth_mode", "Open"))
          config                      = lookup(u, "config", null)
          maintain_start_time         = lookup(u, "maintain_start_time", "16:00Z")
          maintain_end_time           = lookup(t, "maintain_end_time", "20:00Z")
          effective_time              = lookup(t, "effective_time", null)
          order_type                  = lookup(t, "order_type", "UPGRADE")
          ssl_enable                  = title(lookup(u, "ssl_enable", "Disable"))
          force_upgrade               = lookup(u, "force_upgrade", true)
          dedicated_host_group_id     = lookup(u, "dedicated_host_group_id", null)
          coupon_no                   = lookup(u, "coupon_no", null)
          business_info               = lookup(u, "business_info", null)
          auto_use_coupon             = lookup(u, "auto_use_coupon", false)
          instance_release_protection = lookup(u, "instance_release_protection", false)
          global_instance_id          = lookup(u, "global_instance_id", null)
          global_instance             = lookup(u, "global_instance", false)
          backup_period               = lookup(u, "backup_period", ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
          backup_time                 = lookup(u, "backup_time", "20:00Z-21:00Z")
          enable_backup_log           = lookup(u, "enable_backup_log", 0)
          private_connection_prefix   = lookup(u, "private_connection_prefix", u.name)
          private_connection_port     = lookup(u, "private_connection_port", 6379)
          dry_run                     = lookup(u, "dry_run", false)
          tde_status                  = title(lookup(t, "tde_status", "Enabled"))
          encryption_name             = lookup(u, "encryption_name", null)
          encryption_key              = lookup(u, "encryption_key", null)
          role_arn                    = lookup(u, "role_arn", null)
          shard_count                 = lookup(u, "shard_count", null)
          connection_string_prefix    = lookup(u, "connection_string_prefix", null)
          port                        = lookup(u, "port", "6379")
          db_audit                    = lookup(u, "db_audit", true)
          retention                   = lookup(u, "retention", 180)
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
            account_privilege      = lookup(v, "privilege", "RoleReadOnly")
          }
        ] if can(u.account)
      ] if can(t.instance)
    ] if can(s.kvstore)
  ])
}
