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

# 获取交换机ID。
data "alicloud_vswitches" "vswitches" {
  for_each          = { for s in local.vswitch_flat : format("%s", s.vswitch_name) => s }
  vswitch_name      = each.key
  status            = "Available"
  vpc_id            = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
}

# 创建路由表。
resource "alicloud_route_table" "route_table" {
  for_each         = { for s in local.route_table_flat : format("%s", s.route_table_name) => s }
  associate_type   = each.value.associate_type
  description      = each.value.description
  route_table_name = each.key
  tags             = merge(var.tags, each.value.tags)
  vpc_id           = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
}

# 绑定交换机。
resource "alicloud_route_table_attachment" "route_table_attachment" {
  for_each       = { for s in local.route_vswitch_flat : format("%s-%s", s.vswitch_name, s.route_table_name) => s }
  vswitch_id     = data.alicloud_vswitches.vswitches[each.value.vswitch_name].vswitches.0.id
  route_table_id = alicloud_route_table.route_table[each.value.route_table_name].id
}

# 获取对等互联ID。
data "alicloud_vpc_peer_connections" "vpc_peer_connections" {
  for_each             = { for s in local.route_entry_flat : format("%s", s.nexthop) => s... if s.nexthop != null && lower(s.nexthop_type) == "vpcpeer" }
  peer_connection_name = each.key
  status               = "Activated"
}

# 获取云服务器ID。
data "alicloud_instances" "instances" {
  for_each   = { for s in local.route_entry_flat : format("%s", s.nexthop) => s if s.nexthop != null && lower(s.nexthop_type) == "instance" }
  name_regex = each.key
  status     = "Running"
}

# 添加对等互联路由条目。
resource "alicloud_route_entry" "route_entry_vpcpeer" {
  for_each              = { for s in local.route_entry_flat : format("%s-%s-%s", s.route_table_name, s.nexthop_type, s.nexthop) => s if s.nexthop != null && lower(s.nexthop_type) == "vpcpeer" }
  route_table_id        = alicloud_route_table.route_table[each.value.route_table_name].id
  destination_cidrblock = each.value.destination_cidrblock
  nexthop_type          = each.value.nexthop_type
  nexthop_id            = data.alicloud_vpc_peer_connections.vpc_peer_connections[each.value.nexthop].connections.0.id
}
