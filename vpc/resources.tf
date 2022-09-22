# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_group" {
  name_regex = var.res_spec.rg.name
  status = "OK"
}

# 创建专有网络。
resource "alicloud_vpc" "vpc" {
  for_each = { for s in var.res_spec.vpc : format("%s", s.name) => s }
  vpc_name = each.value.name
  cidr_block = each.value.cidr
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_group.groups.0.id
  description = lookup(each.value, "description", null)
  tags = merge(var.tags,each.value.tags)
}

# 添加附加网段。
resource "alicloud_vpc_ipv4_cidr_block" "vpc_ipv4_cidr_block" {
  for_each = { for s in local.secondary_cidr_flat : format("%s", s.secondary_cidr_block) => s }
  vpc_id = alicloud_vpc.vpc[each.value.vpc_name].id
  secondary_cidr_block = each.value.secondary_cidr_block
}