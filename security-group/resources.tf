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

# 获取云服务器安全组ID。
data "alicloud_security_groups" "security_groups" {
  for_each   = { for s in local.security_group_rule_flat : format("%s", s.source_security_group) => s... if s.source_security_group != null }
  name_regex = each.key
}

# 创建云服务器安全组。
resource "alicloud_security_group" "security_group" {
  for_each            = { for s in local.security_group_flat : format("%s", s.name) => s }
  vpc_id              = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  security_group_type = each.value.security_group_type
  name                = each.key
  description         = each.value.description
  resource_group_id   = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  inner_access_policy = each.value.inner_access_policy
  tags                = merge(var.tags, each.value.tags)
}

# 附加云服务器安全组规则。
resource "alicloud_security_group_rule" "security_group_rule" {
  for_each                   = { for s in local.security_group_rule_flat : format("%s-%s-%s-%s-%s-%s", s.name, s.ip_protocol, s.port_range, s.nic_type, s.policy, s.cidr_ip) => s }
  type                       = each.value.type
  ip_protocol                = each.value.ip_protocol
  port_range                 = each.value.port_range
  security_group_id          = alicloud_security_group.security_group[each.value.name].id
  nic_type                   = each.value.nic_type
  policy                     = each.value.policy
  priority                   = each.value.priority
  cidr_ip                    = each.value.cidr_ip
  source_security_group_id   = each.value.source_security_group != null ? data.alicloud_security_groups.security_groups[each.value.source_security_group[0]].groups.0.id : null
  source_group_owner_account = each.value.source_group_owner_account
  description                = each.value.description
  prefix_list_id             = each.value.prefix_list_id
  ipv6_cidr_ip               = each.value.ipv6_cidr_ip
}
