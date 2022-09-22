# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  account_name_flat = flatten([
    for s in var.res_spec.kvstore[*] : [    
      for t in s.account_name : {
          db_instance_name = s.db_instance_name
          account_name = t
      }
    ] if can(s.account_name)
  ])
}