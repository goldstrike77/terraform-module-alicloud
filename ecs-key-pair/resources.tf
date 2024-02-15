# 获取云服务器资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 创建密钥对。
resource "alicloud_ecs_key_pair" "ecs_key_pair" {
  for_each          = { for s in local.ecs_key_pair_flat : format("%s", s.key_pair_name) => s }
  key_file          = each.value.key_file
  key_pair_name     = each.key
  key_name_prefix   = each.value.key_name_prefix
  public_key        = each.value.public_key
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  tags              = merge(var.tags, each.value.tags)
}
