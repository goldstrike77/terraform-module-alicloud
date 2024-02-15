# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources[*].resource_manager_resource_group : {
      resource_group_name = lookup(s, "resource_group_name", s.display_name)
      display_name        = s.display_name
    }
  ])
  ecs_key_pair_flat = flatten([
    for s in var.resources[*] : [
      for t in s.key_pair[*] : {
        display_name    = s.resource_manager_resource_group.display_name
        key_file        = lookup(t, "key_file", null)
        key_pair_name   = t.name
        key_name_prefix = lookup(t, "key_name_prefix", null)
        public_key      = lookup(t, "public_key", null)
        tags            = lookup(t, "tags", {})
      }
    ] if can(s.key_pair)
  ])
}
