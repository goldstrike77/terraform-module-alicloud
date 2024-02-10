# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources[*].resource_manager_resource_group : {
      resource_group_name = lookup(s, "resource_group_name", s.display_name)
      display_name        = s.display_name
    }
  ])
  vpc_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : {
        display_name = s.resource_manager_resource_group.display_name
        cidr_block   = t.cidr_block
        vpc_name     = t.vpc_name
      }
    ]
  ])
  vswitch_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.vswitch : {
          display_name = s.resource_manager_resource_group.display_name
          vpc_name     = t.vpc_name
          vswitch_name = u.vswitch_name
        }
      ]
    ]
  ])
  nat_gateway_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.vswitch[*] : [
          for v in u.nat_gateway : {
            display_name                           = s.resource_manager_resource_group.display_name
            vpc_name                               = t.vpc_name
            specification                          = lookup(v, "specification", "Small")
            nat_gateway_name                       = lookup(v, "nat_gateway_name", null)
            description                            = lookup(v, "description", null)
            dry_run                                = lookup(v, "dry_run", false)
            force                                  = lookup(v, "force", false)
            payment_type                           = lookup(v, "payment_type", "PayAsYouGo")
            period                                 = lookup(v, "period", null)
            nat_type                               = "Enhanced"
            vswitch_name                           = u.vswitch_name
            internet_charge_type                   = "PayByLcu"
            tags                                   = lookup(v, "tags", {})
            deletion_protection                    = lookup(v, "deletion_protection", false)
            network_type                           = lookup(v, "network_type", "internet")
            eip_bind_mode                          = lookup(v, "eip_bind_mode", "MULTI_BINDED")
            eip_activity_id                        = lookup(v, "eip_activity_id", null)
            eip_address_name                       = lookup(v, "eip_address_name", "eip-${v.nat_gateway_name}")
            eip_auto_pay                           = lookup(v, "eip_auto_pay", true)
            eip_bandwidth                          = lookup(v, "eip_bandwidth", 5)
            eip_deletion_protection                = lookup(v, "eip_deletion_protection", false)
            eip_description                        = lookup(v, "eip_description", null)
            eip_high_definition_monitor_log_status = lookup(v, "eip_high_definition_monitor_log_status", null)
            eip_internet_charge_type               = lookup(v, "eip_internet_charge_type", "PayByBandwidth")
            eip_ip_address                         = lookup(v, "eip_ip_address", null)
            eip_isp                                = lookup(v, "eip_isp", "BGP")
            eip_log_project                        = lookup(v, "eip_log_project", null)
            eip_log_store                          = lookup(v, "eip_log_store", null)
            eip_payment_type                       = lookup(v, "eip_payment_type", "PayAsYouGo")
            eip_period                             = lookup(v, "eip_period", null)
            eip_pricing_cycle                      = lookup(v, "eip_pricing_cycle", null)
            eip_public_ip_address_pool_id          = lookup(v, "eip_public_ip_address_pool_id", null)
            eip_security_protection_types          = lookup(v, "eip_security_protection_types", [])
            eip_tags                               = lookup(v, "eip_tags", {})
            eip_zone                               = lookup(v, "eip_zone", null)
            snat_source_cidr                       = lookup(v, "snat_source_cidr", "0.0.0.0/0")
          }
        ] if can(u.nat_gateway)
      ]
    ]
  ])
}
