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
  vpc_ipv4_cidr_block_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for v in t.secondary_cidr_block : {
          cidr_block           = t.cidr_block
          vpc_name             = t.vpc_name
          secondary_cidr_block = v
        }
      ]
    ]
  ])
}
