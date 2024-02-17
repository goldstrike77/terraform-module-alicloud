# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources[*].resource_manager_resource_group : {
      resource_group_name = lookup(s, "resource_group_name", s.display_name)
      display_name        = s.display_name
    }
  ])
  bastionhost_instance_network_flat = flatten([
    for s in var.resources[*] : [
      for t in s.bastionhost : {
        vpc_name       = t.vpc
        vswitch_name   = t.vswitch
        security_group = t.security_group
      }
    ]
  ])
  bastionhost_instance_flat = flatten([
    for s in var.resources[*] : [
      for t in s.bastionhost : {
        display_name         = s.resource_manager_resource_group.display_name
        vpc_name             = t.vpc
        vswitch_name         = t.vswitch
        security_group       = t.security_group
        license_code         = lookup(t, "license_code", "bhah_ent_50_asset")
        plan_code            = lookup(t, "plan_code", "cloudbastion")
        storage              = lookup(t, "storage", 0)
        bandwidth            = lookup(t, "bandwidth", 0)
        description          = lookup(t, "description", null)
        period               = lookup(t, "period", 1)
        tags                 = lookup(t, "tags", {})
        enable_public_access = lookup(t, "enable_public_access", true)
        ad_auth_server       = lookup(t, "ad_auth_server", {})
        ldap_auth_server     = lookup(t, "ldap_auth_server", {})
        renew_period         = lookup(t, "renew_period", 1)
        renewal_status       = lookup(t, "renewal_status", "ManualRenewal")
        renewal_period_unit  = lookup(t, "renewal_period_unit", null)
        public_white_list    = lookup(t, "public_white_list", [])
      }
    ]
  ])
}
