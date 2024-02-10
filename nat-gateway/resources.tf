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

# 添加弹性公网IP。
resource "alicloud_eip_address" "eip_address" {
  for_each                           = { for s in local.nat_gateway_flat : format("%s", s.eip_address_name) => s if s.network_type == "internet" }
  activity_id                        = each.value.eip_activity_id
  address_name                       = each.value.eip_address_name
  auto_pay                           = each.value.eip_auto_pay
  bandwidth                          = each.value.eip_bandwidth
  deletion_protection                = each.value.eip_deletion_protection
  description                        = each.value.eip_description
  high_definition_monitor_log_status = each.value.eip_high_definition_monitor_log_status
  internet_charge_type               = each.value.eip_internet_charge_type
  ip_address                         = each.value.eip_ip_address
  isp                                = each.value.eip_isp
  log_project                        = each.value.eip_log_project
  log_store                          = each.value.eip_log_store
  payment_type                       = each.value.eip_payment_type
  period                             = each.value.eip_period
  pricing_cycle                      = each.value.eip_pricing_cycle
  public_ip_address_pool_id          = each.value.eip_public_ip_address_pool_id
  resource_group_id                  = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  security_protection_types          = each.value.eip_security_protection_types
  tags                               = merge(var.tags, each.value.eip_tags)
  zone                               = each.value.eip_zone
}

# 绑定弹性公网IP。
resource "alicloud_eip_association" "eip_association" {
  for_each      = { for s in local.nat_gateway_flat : format("%s", s.eip_address_name) => s if s.network_type == "internet" }
  allocation_id = alicloud_eip_address.eip_address[each.key].id
  instance_id   = alicloud_nat_gateway.nat_gateway[each.value.nat_gateway_name].id
}

# 创建SNAT条目。
resource "alicloud_snat_entry" "snat_entry" {
  for_each        = { for s in local.nat_gateway_flat : format("%s", s.nat_gateway_name) => s if s.network_type == "internet" }
  snat_entry_name = "snat-${each.key}"
  snat_table_id   = alicloud_nat_gateway.nat_gateway[each.key].snat_table_ids
  source_cidr     = each.value.snat_source_cidr
  snat_ip         = alicloud_eip_address.eip_address[each.value.eip_address_name].ip_address
}
