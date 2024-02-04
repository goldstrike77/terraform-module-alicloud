# 创建资源组。
resource "alicloud_resource_manager_resource_group" "resource_manager_resource_group" {
  for_each            = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  resource_group_name = each.value.resource_group_name
  display_name        = each.key
}
