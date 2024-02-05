# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources[*].resource_manager_resource_group : {
      resource_group_name = lookup(s, "resource_group_name", s.display_name)
      display_name        = s.display_name
    }
  ])
  nat_gateway_flat = flatten([
    for s in var.resources[*] : [
      for t in s.nat_gateway[*] : {
        vpc_name             = t.vpc_name
        specification        = lookup(t, "specification", "Small")
        nat_gateway_name     = lookup(t, "nat_gateway_name", null)
        description          = lookup(t, "description", null)
        dry_run              = lookup(t, "dry_run", false)
        force                = lookup(t, "force", false)
        payment_type         = lookup(t, "payment_type", "PayAsYouGo")
        period               = lookup(t, "period", null)
        nat_type             = "Enhanced"
        vswitch_name         = t.vswitch_name
        internet_charge_type = "PayByLcu"
        tags                 = lookup(t, "tags", {})
        deletion_protection  = lookup(t, "deletion_protection", false)
        network_type         = lookup(t, "network_type", "internet")
        eip_bind_mode        = lookup(t, "eip_bind_mode", "MULTI_BINDED")
      }
    ]
  ])
}
