# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取发起端专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each          = { for s in local.vpc_flat : format("%s", s.vpc_name) => s }
  cidr_block        = each.value.cidr_block
  status            = "Available"
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  vpc_name          = each.key
}

# 获取接收端专有网络ID。
data "alicloud_vpcs" "accepting_vpcs" {
  for_each = { for s in local.vpc_peer_connection_flat : format("%s", s.accepting_vpc) => s }
  status   = "Available"
  vpc_name = each.key
}

# 创建对等连接。
resource "alicloud_vpc_peer_connection" "vpc_peer_connection" {
  for_each             = { for s in local.vpc_peer_connection_flat : format("%s-%s", s.vpc_name, s.accepting_vpc) => s }
  vpc_id               = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  accepting_vpc_id     = data.alicloud_vpcs.accepting_vpcs[each.value.accepting_vpc].vpcs.0.id
  accepting_region_id  = each.value.accepting_region_id
  accepting_ali_uid    = each.value.accepting_ali_uid
  bandwidth            = each.value.bandwidth
  resource_group_id    = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  peer_connection_name = each.value.peer_connection_name
  description          = each.value.description
  status               = each.value.status
  tags                 = merge(var.tags, each.value.tags)
  dry_run              = each.value.dry_run
}
