# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  secondary_cidr_flat = flatten([
    for s in var.res_spec.vpc[*] : [
      for t in s.secondary_cidr : {
        vpc_name = s.name
        secondary_cidr_block = t
      }
    ] if can(s.secondary_cidr)
  ])
}