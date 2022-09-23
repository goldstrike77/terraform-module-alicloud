# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_group" {
  name_regex = var.res_spec.rg.name
  status = "OK"
}

# 获取交换机ID。
data "alicloud_vswitches" "vswitches" {
  for_each = { for s in var.res_spec.kvstore : format("%s", s.vswitch_name) => s if can(s.vswitch_name) }
  status = "Available"
  vswitch_name = each.key
}

# 获取安全组ID。
data "alicloud_security_groups" "security_groups" {
  for_each = { for s in var.res_spec.kvstore : format("%s", s.security_group_name) => s if can(s.security_group_name) }
  name_regex = each.key
}

# 创建 Redis / Memcache 随机密码。
resource "random_password" "password" {
  for_each = { for s in local.kvstore_flat : format("%s", s.name) => s }
  length = 16
  min_lower = 1
  min_numeric = 1
  min_upper = 1
  special = false
  keepers = { name = each.key }
}

# 创建 Redis / Memcache 实例。
resource "alicloud_kvstore_instance" "kvstore_instance" {
  for_each = { for s in local.kvstore_flat : format("%s", s.name) => s }
  db_instance_name = each.key
  password = random_password.password[each.key].result
  instance_class = each.value.instance_class
  capacity = each.value.capacity
  zone_id = each.value.zone_id
  secondary_zone_id = each.value.secondary_zone_id
  payment_type = each.value.payment_type
  period = each.value.period
  auto_renew = each.value.auto_renew
  auto_renew_period = each.value.auto_renew_period
  instance_type  = each.value.instance_type
  vswitch_id = each.value.vswitch_name == "" ? null : data.alicloud_vswitches.vswitches[each.value.vswitch_name].vswitches.0.id
  engine_version = each.value.engine_version
  tags = merge(var.tags,each.value.tags)
  security_ips = each.value.security_ips
  security_group_id = each.value.security_group_name == "" ? null : data.alicloud_security_groups.security_groups[each.value.security_group_name].groups.0.id
  vpc_auth_mode = each.value.vpc_auth_mode
  config = each.value.config
  maintain_start_time = each.value.maintain_start_time
  maintain_end_time = each.value.maintain_end_time
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_group.groups.0.id
  ssl_enable = each.value.ssl_enable
  dry_run = false
}

# 创建 Redis / Memcache 公网连接。
resource "alicloud_kvstore_connection" "kvstore_connection" {
  for_each = { for s in local.kvstore_flat : format("%s", s.name) => s if s.public }
  connection_string_prefix = each.key
  instance_id = alicloud_kvstore_instance.kvstore_instance[each.key].id
  port = each.value.port
}

# 创建 Redis / Memcache 实例审计日志配置。
resource "alicloud_kvstore_audit_log_config" "kvstore_audit_log_config" {
  for_each = { for s in local.kvstore_flat : format("%s", s.name) => s }
  instance_id = alicloud_kvstore_instance.kvstore_instance[each.value.name].id
  db_audit = each.value.db_audit
  retention = each.value.retention
}

# 创建 Redis / Memcache 实例备份配置。
resource "alicloud_kvstore_backup_policy" "kvstore_backup_policy" {
  for_each = { for s in local.kvstore_flat : format("%s", s.name) => s }
  instance_id = alicloud_kvstore_instance.kvstore_instance[each.value.name].id
  backup_period = each.value.backup_period
  backup_time = each.value.backup_time
}

## 创建 Redis / Memcache 随机密码。
#resource "random_password" "password" {
#  for_each = { for s in local.account_name_flat : format("%s-%s", s.name,s.account_name) => s }
#  length = 16
#  min_lower = 1
#  min_numeric = 1
#  min_special = 1
#  min_upper = 1
#  special = true
#  override_special = "!#$%&*()-_=+[]{}<>:?"
#  keepers = {
#    name = each.value.name
#    account_name = each.value.account_name
#  }
#}
#
## 创建 Redis / Memcache 账户。
#resource "alicloud_kvstore_account" "kvstore_account" {
#  for_each = { for s in local.kvstore_account_flat : format("%s-%s", s.name,s.account_name) => s }
#  account_name = each.value.account_name
#  account_password = random_password.password["${each.value.name}-${each.value.account_name}"].result
#  instance_id = alicloud_kvstore_instance.kvstore_instance[each.value.name].id
#}