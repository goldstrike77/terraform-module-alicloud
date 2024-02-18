# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources : {
      resource_group_name = lookup(s.resource_manager_resource_group, "resource_group_name", s.resource_manager_resource_group.display_name)
      display_name        = s.resource_manager_resource_group.display_name
    } if can(s.resource_manager_resource_group)
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
          vpc_name             = t.vpc_name
          cidr_block           = u.cidr_block
          description          = lookup(u, "description", null)
          zone_id              = lookup(u, "zone_id", null)
          enable_ipv6          = lookup(u, "enable_ipv6", false)
          ipv6_cidr_block_mask = lookup(u, "ipv6_cidr_block_mask", null)
          tags                 = lookup(u, "tags", {})
          vswitch_name         = lookup(u, "vswitch_name", null)
        }
      ] if can(t.vswitch)
    ]
  ])
}
