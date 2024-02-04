# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each          = { for s in local.vpc_flat : format("%s", s.vpc_name) => s }
  cidr_block        = each.value.cidr_block
  status            = "Available"
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  vpc_name          = each.key
}

# 添加专有网络附加网段。
resource "alicloud_vpc_ipv4_cidr_block" "vpc_ipv4_cidr_block" {
  for_each             = { for s in local.vpc_ipv4_cidr_block_flat : format("%s", s.secondary_cidr_block) => s }
  vpc_id               = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  secondary_cidr_block = each.key
}
