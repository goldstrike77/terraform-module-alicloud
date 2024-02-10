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
  vpc_peer_connection_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.vpc_peer_connection : {
          display_name         = s.resource_manager_resource_group.display_name
          vpc_name             = t.vpc_name
          accepting_vpc        = u.accepting_vpc
          accepting_region_id  = u.accepting_region_id
          accepting_ali_uid    = u.accepting_ali_uid
          bandwidth            = lookup(u, "bandwidth", null)
          peer_connection_name = lookup(u, "peer_connection_name", "pcc-${t.vpc_name}-peer-${u.accepting_vpc}")
          description          = lookup(u, "description", null)
          status               = lookup(u, "status", null)
          tags                 = lookup(u, "tags", {})
          dry_run              = lookup(u, "dry_run", false)
        }
      ] if can(t.vpc_peer_connection)
    ]
  ])
}
