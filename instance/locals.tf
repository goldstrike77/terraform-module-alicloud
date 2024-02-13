# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources[*].resource_manager_resource_group : {
      resource_group_name = lookup(s, "resource_group_name", s.display_name)
      display_name        = s.display_name
    }
  ])
  ecs_flat = flatten([
    for s in var.resources[*] : [
      for t in s.ecs[*] : [
        for u in t.instance_name : {
          display_name                        = s.resource_manager_resource_group.display_name
          vpc_name                            = t.vpc
          vswitch_name                        = t.vswitch
          image_id                            = lookup(t, "image_id", "rockylinux_8_9_x64_20G_alibase_20231221.vhd")
          instance_type                       = lookup(t, "instance_type", "ecs.g6e.large")
          is_outdated                         = lookup(t, "is_outdated", false)
          security_group                      = lookup(t, "security_group", null)
          instance_name                       = u
          system_disk_category                = lookup(t, "system_disk_category", "cloud_auto")
          system_disk_name                    = lookup(t, "system_disk_name", "d-${u}")
          system_disk_description             = lookup(t, "system_disk_description", null)
          system_disk_size                    = lookup(t, "system_disk_size", 40)
          system_disk_performance_level       = lookup(t, "system_disk_performance_level", "PL1")
          system_disk_auto_snapshot_policy_id = lookup(t, "system_disk_auto_snapshot_policy_id", null)
          system_disk_storage_cluster_id      = lookup(t, "system_disk_storage_cluster_id", null)
          system_disk_encrypted               = lookup(t, "system_disk_encrypted", false)
          system_disk_kms_key_id              = lookup(t, "system_disk_kms_key_id", null)
          system_disk_encrypt_algorithm       = lookup(t, "system_disk_encrypt_algorithm", null)
          description                         = lookup(t, "description", null)
          internet_charge_type                = lookup(t, "internet_charge_type", "PayByTraffic")
          internet_max_bandwidth_out          = lookup(t, "internet_max_bandwidth_out", 0)
          host_name                           = lookup(t, "host_name", u)
          password                            = t.password
          kms_encrypted_password              = lookup(t, "kms_encrypted_password", null)
          kms_encryption_context              = lookup(t, "kms_encryption_context", {})
          instance_charge_type                = lookup(t, "instance_charge_type", "PostPaid")
          period_unit                         = lookup(t, "period_unit", null)
          period                              = lookup(t, "period", null)
          renewal_status                      = lookup(t, "renewal_status", "Normal")
          auto_renew_period                   = lookup(t, "auto_renew_period", null)
          tags                                = lookup(t, "tags", {})
          volume_tags                         = lookup(t, "volume_tags", {})
          user_data                           = lookup(t, "user_data", null)
          key_name                            = lookup(t, "key_name", null)
          role_name                           = lookup(t, "role_name", null)
          dry_run                             = lookup(t, "dry_run", false)
          credit_specification                = lookup(t, "credit_specification", null)
          spot_strategy                       = lookup(t, "spot_strategy", "NoSpot")
          spot_price_limit                    = lookup(t, "spot_price_limit", null)
          deletion_protection                 = lookup(t, "deletion_protection", false)
          force_delete                        = lookup(t, "force_delete", false)
          auto_release_time                   = lookup(t, "auto_release_time", null)
          security_enhancement_strategy       = lookup(t, "security_enhancement_strategy", null)
          status                              = lookup(t, "status", "Running")
          hpc_cluster_id                      = lookup(t, "hpc_cluster_id", null)
          deployment_set_id                   = lookup(t, "deployment_set_id", null)
          operator_type                       = lookup(t, "operator_type", null)
          stopped_mode                        = lookup(t, "stopped_mode", null)
          spot_duration                       = lookup(t, "spot_duration", null)
          http_tokens                         = lookup(t, "http_tokens", null)
          http_endpoint                       = lookup(t, "http_endpoint", null)
          http_put_response_hop_limit         = lookup(t, "http_put_response_hop_limit", 1)
          dedicated_host_id                   = lookup(t, "dedicated_host_id", null)
          launch_template_id                  = lookup(t, "launch_template_id", null)
          launch_template_name                = lookup(t, "launch_template_name", null)
          launch_template_version             = lookup(t, "launch_template_version", null)
        }
      ]
    ]
  ])
  ecs_disk_flat = flatten([
    for s in var.resources[*] : [
      for t in s.ecs[*] : [
        for u in t.instance_name : [
          for v in t.disk : {
            display_name                 = s.resource_manager_resource_group.display_name
            instance_name                = u
            zone_id                      = t.zone_id
            category                     = lookup(v, "category", "cloud_auto")
            delete_auto_snapshot         = lookup(v, "delete_auto_snapshot", false)
            delete_with_instance         = lookup(v, "delete_with_instance", false)
            description                  = lookup(v, "description", null)
            disk_name                    = "d-${u}-${v.name}"
            dry_run                      = lookup(v, "dry_run", false)
            enable_auto_snapshot         = lookup(v, "enable_auto_snapshot", false)
            encrypted                    = lookup(v, "encrypted", null)
            kms_key_id                   = lookup(v, "kms_key_id", null)
            payment_type                 = lookup(v, "payment_type", "PayAsYouGo")
            performance_level            = lookup(v, "performance_level", "PL1")
            tags                         = lookup(v, "tags", {})
            size                         = v.size
            snapshot_id                  = lookup(v, "snapshot_id", null)
            storage_set_id               = lookup(v, "storage_set_id", null)
            storage_set_partition_number = lookup(v, "storage_set_partition_number", null)
            type                         = lookup(v, "type", "offline")
          }
        ]
      ] if can(t.disk)
    ]
  ])
  ecs_network_interface_flat = flatten([
    for s in var.resources[*] : [
      for t in s.ecs[*] : [
        for u in t.instance_name : [
          for v in t.network_interface : {
            display_name                       = s.resource_manager_resource_group.display_name
            instance_name                      = u
            vpc_name                           = v.vpc
            description                        = lookup(v, "description", null)
            network_interface_name             = "eni-${u}-${v.name}"
            primary_ip_address                 = lookup(v, "primary_ip_address", null)
            private_ip_addresses               = lookup(v, "private_ip_addresses", null)
            queue_number                       = lookup(v, "queue_number", null)
            secondary_private_ip_address_count = lookup(v, "secondary_private_ip_address_count", null)
            security_group                     = v.security_group
            vswitch_name                       = v.vswitch
            tags                               = lookup(v, "tags", {})
            ipv6_address_count                 = lookup(v, "ipv6_address_count", null)
            ipv6_addresses                     = lookup(v, "ipv6_addresses", null)
            ipv4_prefix_count                  = lookup(v, "ipv4_prefix_count", null)
            ipv4_prefixes                      = lookup(v, "ipv4_prefixes", null)
          }
        ]
      ] if can(t.network_interface)
    ]
  ])
}
