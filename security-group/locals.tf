# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  resource_manager_resource_group_flat = flatten([
    for s in var.resources : {
      resource_group_name = lookup(s.resource_manager_resource_group, "resource_group_name", s.resource_manager_resource_group.display_name)
      display_name        = s.resource_manager_resource_group.display_name
    } if can(s.resource_manager_resource_group)
  ])
  vpc_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : {
        display_name = s.resource_manager_resource_group.display_name
        cidr_block   = t.cidr_block
        vpc_name     = t.vpc_name
      }
    ] if can(s.vpc)
  ])
  security_group_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.security_group : {
          display_name        = s.resource_manager_resource_group.display_name
          vpc_name            = t.vpc_name
          security_group_type = lower(lookup(u, "security_group_type", "normal"))
          name                = u.name
          description         = lookup(u, "description", "Descriptions.")
          inner_access_policy = title(lookup(u, "inner_access_policy", "Drop"))
          tags                = lookup(u, "tags", {})
        }
      ] if can(t.security_group)
    ] if can(s.vpc)
  ])
  security_group_rule_flat = flatten([
    for s in var.resources[*] : [
      for t in s.vpc[*] : [
        for u in t.security_group : [
          for v in u.rule : {
            name                       = u.name
            type                       = lower(lookup(v, "type", "ingress"))
            ip_protocol                = lower(lookup(v, "ip_protocol", "tcp"))
            port_range                 = lookup(v, "port_range", "-1/-1")
            nic_type                   = lower(lookup(v, "nic_type", "intranet"))
            policy                     = lower(lookup(v, "policy", "accept"))
            priority                   = lookup(v, "priority", 1)
            cidr_ip                    = lookup(v, "cidr_ip", "0.0.0.0/0")
            source_security_group      = lookup(v, "source_security_group", null)
            source_group_owner_account = lookup(v, "source_group_owner_account", null)
            description                = lookup(v, "description", null)
            prefix_list_id             = lookup(v, "prefix_list_id", null)
            ipv6_cidr_ip               = lookup(v, "ipv6_cidr_ip", null)
          }
        ] if can(u.rule)
      ] if can(t.security_group)
    ] if can(s.vpc)
  ])
}
