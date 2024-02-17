# 获取堡垒机资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取堡垒机专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each = { for s in local.bastionhost_instance_network_flat : format("%s", s.vpc_name) => s... }
  status   = "Available"
  vpc_name = each.key
}

# 获取堡垒机交换机ID。
data "alicloud_vswitches" "vswitches" {
  for_each     = { for s in local.bastionhost_instance_network_flat : format("%s", s.vswitch_name) => s... }
  vswitch_name = each.key
  status       = "Available"
  vpc_id       = data.alicloud_vpcs.vpcs[each.value[0].vpc_name].vpcs.0.id
}

# 获取堡垒机安全组ID。
data "alicloud_security_groups" "security_groups" {
  for_each   = { for s in local.bastionhost_instance_network_flat : format("%s", s.security_group) => s... }
  name_regex = each.key
}

# 创建堡垒机。
resource "alicloud_bastionhost_instance" "bastionhost_instance" {
  for_each             = { for s in local.bastionhost_instance_flat : format("%s", s.description) => s }
  license_code         = each.value.license_code
  plan_code            = each.value.plan_code
  storage              = each.value.storage
  bandwidth            = each.value.bandwidth
  description          = each.key
  period               = each.value.period
  vswitch_id           = data.alicloud_vswitches.vswitches[each.value.vswitch_name].vswitches.0.id
  security_group_ids   = data.alicloud_security_groups.security_groups[each.value.security_group].ids
  tags                 = merge(var.tags, each.value.tags)
  resource_group_id    = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  enable_public_access = each.value.enable_public_access
  dynamic "ad_auth_server" {
    for_each = each.value.ad_auth_server == {} ? [] : [1]
    content {
      account        = each.value.ad_auth_server.account
      base_dn        = each.value.ad_auth_server.base_dn
      domain         = each.value.ad_auth_server.domain
      email_mapping  = lookup(each.value.ad_auth_server, "email_mapping", "emailAttr")
      filter         = lookup(each.value.ad_auth_server, "filter", "objectClass=person")
      is_ssl         = lookup(each.value.ad_auth_server, "is_ssl", false)
      mobile_mapping = lookup(each.value.ad_auth_server, "mobile_mapping", "mobileAttr")
      name_mapping   = lookup(each.value.ad_auth_server, "name_mapping", "nameAttr")
      password       = each.value.ad_auth_server.password
      port           = each.value.ad_auth_server.port
      server         = each.value.ad_auth_server.server
      standby_server = lookup(each.value.ad_auth_server, "standby_server", null)
    }
  }
  dynamic "ldap_auth_server" {
    for_each = each.value.ldap_auth_server == {} ? [] : [1]
    content {
      account            = each.value.ldap_auth_server.account
      base_dn            = each.value.ldap_auth_server.base_dn
      email_mapping      = lookup(each.value.ldap_auth_server, "email_mapping", "emailAttr")
      filter             = lookup(each.value.ldap_auth_server, "filter", "objectClass=person")
      is_ssl             = lookup(each.value.ldap_auth_server, "is_ssl", false)
      login_name_mapping = lookup(each.value.ldap_auth_server, "login_name_mapping", "uid")
      mobile_mapping     = lookup(each.value.ldap_auth_server, "mobile_mapping", "mobileAttr")
      name_mapping       = lookup(each.value.ldap_auth_server, "name_mapping", "nameAttr")
      password           = each.value.ldap_auth_server.password
      port               = each.value.ldap_auth_server.port
      server             = each.value.ldap_auth_server.server
      standby_server     = lookup(each.value.ldap_auth_server, "standby_server", null)
    }
  }
  renew_period        = each.value.renew_period
  renewal_status      = each.value.renewal_status
  renewal_period_unit = each.value.renewal_period_unit
  public_white_list   = each.value.public_white_list
}
