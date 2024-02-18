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
  route_table_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.route_table : {
          display_name     = s.resource_manager_resource_group.display_name
          vpc_name         = t.vpc_name
          associate_type   = lookup(u, "associate_type", "VSwitch")
          description      = lookup(u, "description", null)
          route_table_name = lookup(u, "route_table_name", "vtb-${t.vpc_name}")
          tags             = lookup(t, "tags", {})
        }
      ] if can(t.route_table)
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
      ] if can(t.vswitch)
    ]
  ])
  route_vswitch_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.vswitch : [
          for v in t.route_table : {
            vswitch_name     = lookup(u, "vswitch_name", null)
            route_table_name = lookup(v, "route_table_name", "vtb-${t.vpc_name}")
          }
        ] if can(t.route_table)
      ] if can(t.vswitch)
    ]
  ])
  route_entry_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.route_table[*] : [
          for v in u.route_entry :
          {
            route_table_name      = lookup(u, "route_table_name", "vtb-${t.vpc_name}")
            destination_cidrblock = lookup(v, "destination_cidrblock", "0.0.0.0/0")
            nexthop_type          = lookup(v, "nexthop_type", "Instance")
            nexthop               = lookup(v, "nexthop", null)
          }
        ] if can(u.route_entry)
      ] if can(t.route_table)
    ]
  ])
}
