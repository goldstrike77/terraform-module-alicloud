# 获取资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取专有网络ID。
data "alicloud_vpcs" "vpcs" {
  for_each = { for s in local.db_instance_flat : format("%s", s.vpc_name) => s... }
  status   = "Available"
  vpc_name = each.key
}

# 获取交换机ID。
data "alicloud_vswitches" "vswitches" {
  for_each     = { for s in local.db_instance_flat : format("%s", s.vswitch_name) => s... }
  vswitch_name = each.key
  status       = "Available"
  vpc_id       = data.alicloud_vpcs.vpcs[each.value[0].vpc_name].vpcs.0.id
}

# 获取安全组ID。
data "alicloud_security_groups" "security_groups" {
  for_each   = { for s in local.db_instance_flat : format("%s", s.security_group) => s... }
  name_regex = each.key
}

# 创建 RDS 实例。
resource "alicloud_db_instance" "db_instance" {
  for_each                       = { for s in local.db_instance_flat : format("%s", s.instance_name) => s }
  engine                         = each.value.engine
  engine_version                 = each.value.engine_version
  instance_type                  = each.value.instance_type
  instance_storage               = each.value.instance_storage
  db_instance_storage_type       = each.value.db_instance_storage_type
  db_time_zone                   = each.value.db_time_zone
  sql_collector_status           = each.value.sql_collector_status
  sql_collector_config_value     = each.value.sql_collector_config_value
  instance_name                  = each.key
  connection_string_prefix       = each.value.connection_string_prefix
  port                           = each.value.port
  instance_charge_type           = each.value.instance_charge_type
  resource_group_id              = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  period                         = each.value.period
  monitoring_period              = each.value.monitoring_period
  auto_renew                     = each.value.auto_renew
  auto_renew_period              = each.value.auto_renew_period
  zone_id                        = each.value.zone_id
  vswitch_id                     = data.alicloud_vswitches.vswitches[each.value.vswitch_name].vswitches.0.id
  private_ip_address             = each.value.private_ip_address
  security_ips                   = each.value.security_ips
  db_instance_ip_array_name      = each.value.db_instance_ip_array_name
  db_instance_ip_array_attribute = each.value.db_instance_ip_array_attribute
  security_ip_type               = each.value.security_ip_type
  db_is_ignore_case              = each.value.db_is_ignore_case
  whitelist_network_type         = each.value.whitelist_network_type
  modify_mode                    = each.value.modify_mode
  security_ip_mode               = each.value.security_ip_mode
  fresh_white_list_readins       = each.value.fresh_white_list_readins
  dynamic "parameters" {
    for_each = each.value.parameters == [] ? [] : [1]
    content {
      name  = each.value.parameters.name
      value = each.value.parameters.value
    }
  }
  force_restart               = each.value.force_restart
  tags                        = merge(var.tags, each.value.tags)
  security_group_ids          = [data.alicloud_security_groups.security_groups[each.value.security_group].groups.0.id]
  maintain_time               = each.value.maintain_time
  auto_upgrade_minor_version  = each.value.auto_upgrade_minor_version
  upgrade_time                = each.value.upgrade_time
  switch_time                 = each.value.switch_time
  target_minor_version        = each.value.target_minor_version
  zone_id_slave_a             = each.value.zone_id_slave_a
  ssl_action                  = each.value.ssl_action
  ssl_connection_string       = each.value.ssl_connection_string
  tde_status                  = each.value.tde_status
  encryption_key              = each.value.encryption_key
  ca_type                     = each.value.ca_type
  server_cert                 = each.value.server_cert
  server_key                  = each.value.server_key
  client_ca_enabled           = each.value.client_ca_enabled
  client_ca_cert              = each.value.client_ca_cert
  client_crl_enabled          = each.value.client_crl_enabled
  client_cert_revocation_list = each.value.client_cert_revocation_list
  acl                         = each.value.acl
  replication_acl             = each.value.replication_acl
  ha_config                   = each.value.ha_config
  manual_ha_time              = each.value.manual_ha_time
  released_keep_policy        = each.value.released_keep_policy
  storage_auto_scale          = each.value.storage_auto_scale
  storage_threshold           = each.value.storage_threshold
  storage_upper_bound         = each.value.storage_upper_bound
  deletion_protection         = each.value.deletion_protection
  tcp_connection_type         = each.value.tcp_connection_type
  category                    = each.value.category
  dynamic "pg_hba_conf" {
    for_each = each.value.pg_hba_conf == {} ? [] : [1]
    content {
      type        = lower(lookup(each.value.pg_hba_conf, "type", "host"))
      mask        = lookup(each.value.pg_hba_conf, "mask", null)
      database    = each.value.pg_hba_conf.database
      priority_id = each.value.pg_hba_conf.priority_id
      address     = each.value.pg_hba_conf.address
      user        = each.value.pg_hba_conf.user
      method      = lookup(each.value.pg_hba_conf, "method", "scram-sha-256")
      option      = lookup(each.value.pg_hba_conf, "option", null)
    }
  }
  babelfish_port = each.value.babelfish_port
  dynamic "babelfish_config" {
    for_each = each.value.babelfish_config == {} ? [] : [1]
    content {
      babelfish_enabled    = each.value.babelfish_config.babelfish_enabled
      migration_mode       = lower(lookup(each.value.babelfish_config, "migration_mode", "single-db"))
      master_username      = each.value.babelfish_config.master_username
      master_user_password = each.value.babelfish_config.master_user_password
    }
  }
  vpc_id         = data.alicloud_vpcs.vpcs[each.value.vpc_name].vpcs.0.id
  effective_time = each.value.effective_time
  dynamic "serverless_config" {
    for_each = each.value.serverless_config == {} ? [] : [1]
    content {
      max_capacity = each.value.serverless_config.max_capacity
      min_capacity = each.value.serverless_config.min_capacity
      auto_pause   = lookup(each.value.serverless_config, "auto_pause", false)
      switch_force = lookup(each.value.serverless_config, "switch_force", false)
    }
  }
  role_arn  = each.value.role_arn
  direction = each.value.direction
  node_id   = each.value.node_id
  force     = each.value.force
}
