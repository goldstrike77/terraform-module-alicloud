# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 创建专有网络。
resource "alicloud_vpc" "vpc" {
  for_each             = { for s in local.vpc_flat : format("%s", s.vpc_name) => s }
  cidr_block           = each.value.cidr_block
  classic_link_enabled = each.value.classic_link_enabled
  description          = each.value.description
  dry_run              = each.value.dry_run
  enable_ipv6          = each.value.enable_ipv6
  ipv6_isp             = each.value.ipv6_isp
  resource_group_id    = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  tags                 = merge(var.tags, each.value.tags)
  user_cidrs           = each.value.user_cidrs
  vpc_name             = each.key
}
