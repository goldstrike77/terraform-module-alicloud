# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_group" {
  name_regex = var.res_spec.rg.name
  status     = "OK"
}

# 获取专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each   = { for s in var.res_spec.vpc : format("%s", s.name) => s }
  cidr_block = each.value.cidr
  status     = "Available"
  vpc_name   = each.value.name
}

# 创建安全组。
resource "alicloud_security_group" "security_group" {
  for_each            = { for s in local.security_group_flat : format("%s", s.name) => s }
  name                = each.value.name
  vpc_id              = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  resource_group_id   = data.alicloud_resource_manager_resource_groups.resource_group.groups.0.id
  inner_access_policy = each.value.inner_access_policy
  description         = each.value.description
  tags                = merge(var.tags, each.value.tags)
}

# 附加安全组规则。
resource "alicloud_security_group_rule" "security_group_rule" {
  for_each          = { for s in local.security_group_rule_flat : format("%s-%s-%s-%s-%s-%s", s.name, s.ip_protocol, s.port_range, s.nic_type, s.policy, s.cidr_ip) => s }
  security_group_id = alicloud_security_group.security_group[each.value.name].id
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  priority          = each.value.priority
  cidr_ip           = each.value.cidr_ip
}
