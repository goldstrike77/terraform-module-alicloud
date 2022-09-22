# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  security_group_flat = flatten([
    for s in var.res_spec.vpc[*] : [    
      for t in s.security_group : {
          name = t.name
          vpc_name = s.name
          inner_access_policy = t.inner_access_policy
          description = lookup(t, "description", "")
          tags = lookup(t, "tags", {})
      }
    ] if can(s.security_group)
  ])
  security_group_rule_flat = flatten([
    for s in var.res_spec.vpc[*] : [    
      for t in s.security_group[*] : [
        for k in t.rule : {
          name = t.name
          type = k.type
          ip_protocol = k.ip_protocol
          port_range = k.port_range
          nic_type = k.nic_type
          policy = k.policy
          priority = k.priority
          cidr_ip = k.cidr_ip
        }
      ] if can(t.rule)
    ] if can(s.security_group)
  ])
}