# 获取专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each = { for s in var.res_spec.vpc : format("%s", s.name) => s }
  cidr_block = each.value.cidr
  status = "Available"
  name_regex = each.value.name
}

# 创建交换机。
resource "alicloud_vswitch" "vswitch" {
  for_each = { for s in local.vswitch_flat : format("%s", s.vswitch_name) => s }
  vswitch_name = each.value.vswitch_name
  vpc_id = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  cidr_block = each.value.cidr
  zone_id = each.value.zone_id
  description = each.value.description
  tags = merge(var.tags,each.value.tags)
}