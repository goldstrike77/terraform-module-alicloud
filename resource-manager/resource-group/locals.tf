# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources : {
      resource_group_name = lookup(s.resource_manager_resource_group, "resource_group_name", s.resource_manager_resource_group.display_name)
      display_name        = s.resource_manager_resource_group.display_name
    } if can(s.resource_manager_resource_group)
  ])
}
