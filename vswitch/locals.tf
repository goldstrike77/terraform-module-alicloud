# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  vswitch_flat = flatten([
    for s in var.res_spec.vpc[*] : [
      for t in s.vswitch : {
        vswitch_name = t.name
        cidr = t.cidr
        zone_id = t.zone_id
        vpc_name = s.name
        description = lookup(t, "description", null)
        tags = lookup(t, "tags", null)
      }
    ]
  ])
}