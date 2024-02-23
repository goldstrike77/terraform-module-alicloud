# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each = { for s in local.kvstore_instance_flat : format("%s", s.vpc_name) => s... }
  status   = "Available"
  vpc_name = each.key
}

# 获取交换机ID。
data "alicloud_vswitches" "vswitches" {
  for_each     = { for s in local.kvstore_instance_flat : format("%s", s.vswitch_name) => s... }
  vswitch_name = each.key
  status       = "Available"
  vpc_id       = data.alicloud_vpcs.vpcs[each.value[0].vpc_name].vpcs.0.id
}

# 获取安全组ID。
data "alicloud_security_groups" "security_groups" {
  for_each   = { for s in local.security_group_flat : format("%s", s.security_group) => s... }
  name_regex = each.key
  vpc_id     = data.alicloud_vpcs.vpcs[each.value[0].vpc_name].vpcs.0.id
}

# 创建 Redis / Memcache 实例。
resource "alicloud_kvstore_instance" "kvstore_instance" {
  for_each                    = { for s in local.kvstore_instance_flat : format("%s", s.db_instance_name) => s }
  db_instance_name            = each.key
  password                    = each.value.password
  kms_encrypted_password      = each.value.kms_encrypted_password
  kms_encryption_context      = each.value.kms_encryption_context
  instance_class              = each.value.instance_class
  capacity                    = each.value.capacity
  zone_id                     = each.value.zone_id
  secondary_zone_id           = each.value.secondary_zone_id
  payment_type                = each.value.payment_type
  period                      = each.value.period
  auto_renew                  = each.value.auto_renew
  auto_renew_period           = each.value.auto_renew_period
  instance_type               = each.value.instance_type
  vswitch_id                  = data.alicloud_vswitches.vswitches[each.value.vswitch_name].vswitches.0.id
  engine_version              = each.value.engine_version
  tags                        = merge(var.tags, each.value.tags)
  security_ips                = each.value.security_ips
  security_ip_group_attribute = each.value.security_ip_group_attribute
  security_ip_group_name      = each.value.security_ip_group_name
  security_group_id           = join(",", [for l in each.value.security_group : data.alicloud_security_groups.security_groups[l].groups.0.id])
  private_ip                  = each.value.private_ip
  backup_id                   = each.value.backup_id
  srcdb_instance_id           = each.value.srcdb_instance_id
  restore_time                = each.value.restore_time
  vpc_auth_mode               = each.value.vpc_auth_mode
  config                      = each.value.config
  maintain_start_time         = each.value.maintain_start_time
  maintain_end_time           = each.value.maintain_end_time
  effective_time              = each.value.effective_time
  resource_group_id           = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  order_type                  = each.value.order_type
  ssl_enable                  = each.value.ssl_enable
  force_upgrade               = each.value.force_upgrade
  dedicated_host_group_id     = each.value.dedicated_host_group_id
  coupon_no                   = each.value.coupon_no
  business_info               = each.value.business_info
  auto_use_coupon             = each.value.auto_use_coupon
  instance_release_protection = each.value.instance_release_protection
  global_instance_id          = each.value.global_instance_id
  global_instance             = each.value.global_instance
  enable_backup_log           = each.value.enable_backup_log
  private_connection_prefix   = each.value.private_connection_prefix
  private_connection_port     = each.value.private_connection_port
  dry_run                     = each.value.dry_run
  #tde_status                  = each.value.tde_status
  encryption_name = each.value.encryption_name
  encryption_key  = each.value.encryption_key
  role_arn        = each.value.role_arn
  shard_count     = each.value.shard_count
}

# 配置 Redis / Memcache 实例公网连接。
resource "alicloud_kvstore_connection" "kvstore_connection" {
  for_each                 = { for s in local.kvstore_instance_flat : format("%s", s.db_instance_name) => s if s.connection_string_prefix != null }
  connection_string_prefix = each.value.connection_string_prefix
  instance_id              = alicloud_kvstore_instance.kvstore_instance[each.key].id
  port                     = each.value.port
}

# 配置 Redis / Memcache 实例审计日志。
resource "alicloud_kvstore_audit_log_config" "kvstore_audit_log_config" {
  for_each    = { for s in local.kvstore_instance_flat : format("%s", s.db_instance_name) => s if s.db_audit }
  instance_id = alicloud_kvstore_instance.kvstore_instance[each.key].id
  db_audit    = each.value.db_audit
  retention   = each.value.retention
}

# 配置 Redis / Memcache 账户权限。
resource "alicloud_kvstore_account" "kvstore_account" {
  for_each               = { for s in local.kvstore_account_flat : format("%s", s.account_name) => s }
  account_name           = each.key
  account_password       = each.value.account_password
  description            = each.value.description
  instance_id            = alicloud_kvstore_instance.kvstore_instance[each.value.db_instance_name].id
  kms_encrypted_password = each.value.kms_encrypted_password
  kms_encryption_context = each.value.kms_encryption_context
  account_type           = each.value.account_type
  account_privilege      = each.value.account_privilege
}

# 配置 Redis / Memcache 备份策略。
resource "alicloud_kvstore_backup_policy" "kvstore_backup_policy" {
  for_each      = { for s in local.kvstore_instance_flat : format("%s", s.db_instance_name) => s if s.backup_period != [] }
  instance_id   = alicloud_kvstore_instance.kvstore_instance[each.key].id
  backup_period = each.value.backup_period
  backup_time   = each.value.backup_time
}
