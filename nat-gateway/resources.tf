# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each          = { for s in local.nat_gateway_flat : format("%s", s.vpc_name) => s }
  status            = "Available"
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  vpc_name          = each.key
}

# 获取交换机ID。
data "alicloud_vswitches" "vswitches" {
  for_each          = { for s in local.nat_gateway_flat : format("%s", s.vswitch_name) => s }
  vswitch_name      = each.key
  status            = "Available"
  vpc_id            = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
}

# 添加NAT网关。
resource "alicloud_nat_gateway" "nat_gateway" {
  for_each             = { for s in local.nat_gateway_flat : format("%s", s.nat_gateway_name) => s }
  vpc_id               = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  specification        = each.value.specification
  nat_gateway_name     = each.key
  description          = each.value.description
  dry_run              = each.value.dry_run
  force                = each.value.force
  payment_type         = each.value.payment_type
  period               = each.value.period
  nat_type             = each.value.nat_type
  vswitch_id           = data.alicloud_vswitches.vswitches[each.value.vswitch_name].vswitches.0.id
  internet_charge_type = each.value.internet_charge_type
  tags                 = merge(var.tags, each.value.tags)
  deletion_protection  = each.value.deletion_protection
  network_type         = each.value.network_type
  eip_bind_mode        = each.value.eip_bind_mode
}
