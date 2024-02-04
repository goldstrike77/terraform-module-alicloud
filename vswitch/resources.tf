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

# 获取可用区ID。
data "alicloud_zones" "zones" {
  available_resource_creation = "VSwitch"
  network_type                = "Vpc"
}

# 创建交换机。
resource "alicloud_vswitch" "vswitch" {
  for_each             = { for s in local.vswitch_flat : format("%s", s.vswitch_name) => s }
  cidr_block           = each.value.cidr_block
  description          = each.value.description
  zone_id              = each.value.zone_id != null ? each.value.zone_id : data.alicloud_zones.zones.zones.0.id
  enable_ipv6          = each.value.enable_ipv6
  ipv6_cidr_block_mask = each.value.ipv6_cidr_block_mask
  tags                 = merge(var.tags, each.value.tags)
  vswitch_name         = each.key
  vpc_id               = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
}
