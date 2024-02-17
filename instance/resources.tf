# 获取云服务器资源组ID。
data "alicloud_resource_manager_resource_groups" "resource_manager_resource_groups" {
  for_each   = { for s in local.resource_manager_resource_group_flat : format("%s", s.display_name) => s }
  name_regex = each.key
  status     = "OK"
}

# 获取云服务器专有网络ID。
data "alicloud_vpcs" "vpcs_ecs" {
  for_each = { for s in local.ecs_flat : format("%s", s.vpc_name) => s... }
  status   = "Available"
  vpc_name = each.key
}

# 获取云服务器交换机ID。
data "alicloud_vswitches" "vswitches_ecs" {
  for_each     = { for s in local.ecs_flat : format("%s", s.vswitch_name) => s... }
  vswitch_name = each.key
  status       = "Available"
  vpc_id       = data.alicloud_vpcs.vpcs_ecs[each.value[0].vpc_name].vpcs.0.id
}

# 获取云服务器安全组ID。
data "alicloud_security_groups" "security_groups_ecs" {
  for_each   = { for s in local.ecs_flat : format("%s", s.security_group) => s... }
  name_regex = each.key
}

# 获取弹性网卡专有网络ID。
data "alicloud_vpcs" "vpcs_ecs_network_interface" {
  for_each = { for s in local.ecs_network_interface_flat : format("%s", s.vpc_name) => s... }
  status   = "Available"
  vpc_name = each.key
}

# 获取弹性网卡交换机ID。
data "alicloud_vswitches" "vswitches_ecs_network_interface" {
  for_each     = { for s in local.ecs_network_interface_flat : format("%s", s.vswitch_name) => s... }
  vswitch_name = each.key
  status       = "Available"
  vpc_id       = data.alicloud_vpcs.vpcs_ecs_network_interface[each.value[0].vpc_name].vpcs.0.id
}

# 获取弹性网卡安全组ID。
data "alicloud_security_groups" "security_groups_ecs_network_interface" {
  for_each   = { for s in local.ecs_network_interface_flat : format("%s", s.security_group) => s... }
  name_regex = each.key
}

# 创建云盘。
resource "alicloud_ecs_disk" "ecs_disk" {
  for_each                     = { for s in local.ecs_disk_flat : format("%s", s.disk_name) => s }
  zone_id                      = each.value.zone_id
  category                     = each.value.category
  delete_auto_snapshot         = each.value.delete_auto_snapshot
  delete_with_instance         = each.value.delete_with_instance
  description                  = each.value.description
  disk_name                    = each.key
  dry_run                      = each.value.dry_run
  enable_auto_snapshot         = each.value.enable_auto_snapshot
  encrypted                    = each.value.encrypted
  kms_key_id                   = each.value.kms_key_id
  payment_type                 = each.value.payment_type
  performance_level            = each.value.performance_level
  tags                         = merge(var.tags, each.value.tags)
  resource_group_id            = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  size                         = each.value.size
  snapshot_id                  = each.value.snapshot_id
  storage_set_id               = each.value.storage_set_id
  storage_set_partition_number = each.value.storage_set_partition_number
  type                         = each.value.type
}

# 创建弹性网卡。
resource "alicloud_ecs_network_interface" "ecs_network_interface" {
  for_each                           = { for s in local.ecs_network_interface_flat : format("%s", s.network_interface_name) => s }
  description                        = each.value.description
  network_interface_name             = each.key
  primary_ip_address                 = each.value.primary_ip_address
  private_ip_addresses               = each.value.private_ip_addresses
  queue_number                       = each.value.queue_number
  resource_group_id                  = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  secondary_private_ip_address_count = each.value.secondary_private_ip_address_count
  security_group_ids                 = data.alicloud_security_groups.security_groups_ecs_network_interface[each.value.security_group].ids
  vswitch_id                         = data.alicloud_vswitches.vswitches_ecs_network_interface[each.value.vswitch_name].vswitches.0.id
  tags                               = merge(var.tags, each.value.tags)
  ipv6_address_count                 = each.value.ipv6_address_count
  ipv6_addresses                     = each.value.ipv6_addresses
  ipv4_prefix_count                  = each.value.ipv4_prefix_count
  ipv4_prefixes                      = each.value.ipv4_prefixes
}

# 创建云服务器。
resource "alicloud_instance" "instance" {
  for_each                            = { for s in local.ecs_flat : format("%s", s.instance_name) => s }
  image_id                            = each.value.image_id
  instance_type                       = each.value.instance_type
  is_outdated                         = each.value.is_outdated
  security_groups                     = data.alicloud_security_groups.security_groups_ecs[each.value.security_group].ids
  instance_name                       = each.key
  system_disk_category                = each.value.system_disk_category
  system_disk_name                    = each.value.system_disk_name
  system_disk_description             = each.value.system_disk_description
  system_disk_size                    = each.value.system_disk_size
  system_disk_performance_level       = each.value.system_disk_performance_level
  system_disk_auto_snapshot_policy_id = each.value.system_disk_auto_snapshot_policy_id
  system_disk_storage_cluster_id      = each.value.system_disk_storage_cluster_id
  system_disk_encrypted               = each.value.system_disk_encrypted
  system_disk_kms_key_id              = each.value.system_disk_kms_key_id
  system_disk_encrypt_algorithm       = each.value.system_disk_encrypt_algorithm
  description                         = each.value.description
  internet_charge_type                = each.value.internet_charge_type
  internet_max_bandwidth_out          = each.value.internet_max_bandwidth_out
  host_name                           = each.value.host_name
  password                            = each.value.password
  kms_encrypted_password              = each.value.kms_encrypted_password
  kms_encryption_context              = each.value.kms_encryption_context
  vswitch_id                          = data.alicloud_vswitches.vswitches_ecs[each.value.vswitch_name].vswitches.0.id
  instance_charge_type                = each.value.instance_charge_type
  resource_group_id                   = data.alicloud_resource_manager_resource_groups.resource_manager_resource_groups[each.value.display_name].groups.0.id
  period_unit                         = each.value.period_unit
  period                              = each.value.period
  renewal_status                      = each.value.renewal_status
  auto_renew_period                   = each.value.auto_renew_period
  tags                                = merge(var.tags, each.value.tags)
  volume_tags                         = each.value.volume_tags
  user_data                           = each.value.user_data
  key_name                            = each.value.key_name
  role_name                           = each.value.role_name
  dry_run                             = each.value.dry_run
  credit_specification                = each.value.credit_specification
  spot_strategy                       = each.value.spot_strategy
  spot_price_limit                    = each.value.spot_price_limit
  deletion_protection                 = each.value.deletion_protection
  force_delete                        = each.value.force_delete
  auto_release_time                   = each.value.auto_release_time
  security_enhancement_strategy       = each.value.security_enhancement_strategy
  status                              = each.value.status
  hpc_cluster_id                      = each.value.hpc_cluster_id
  deployment_set_id                   = each.value.deployment_set_id
  operator_type                       = each.value.operator_type
  stopped_mode                        = each.value.stopped_mode
  spot_duration                       = each.value.spot_duration
  http_tokens                         = each.value.http_tokens
  http_endpoint                       = each.value.http_endpoint
  http_put_response_hop_limit         = each.value.http_put_response_hop_limit
  dedicated_host_id                   = each.value.dedicated_host_id
  launch_template_id                  = each.value.launch_template_id
  launch_template_name                = each.value.launch_template_name
  launch_template_version             = each.value.launch_template_version
}

# 附加云盘。
resource "alicloud_ecs_disk_attachment" "ecs_disk_attachment" {
  for_each    = { for s in local.ecs_disk_flat : format("%s", s.disk_name) => s }
  disk_id     = alicloud_ecs_disk.ecs_disk[each.key].id
  instance_id = alicloud_instance.instance[each.value.instance_name].id
}

# 附加弹性网卡。
resource "alicloud_ecs_network_interface_attachment" "ecs_network_interface_attachment" {
  for_each             = { for s in local.ecs_network_interface_flat : format("%s", s.network_interface_name) => s }
  network_interface_id = alicloud_ecs_network_interface.ecs_network_interface[each.key].id
  instance_id          = alicloud_instance.instance[each.value.instance_name].id
}

# 附加密钥对。
resource "alicloud_ecs_key_pair_attachment" "ecs_key_pair_attachment" {
  for_each      = { for s in local.ecs_flat : format("%s", s.instance_name) => s if s.key_pair_name != null }
  key_pair_name = each.value.key_pair_name
  instance_ids  = [alicloud_instance.instance[each.key].id]
}

# 配置整机备份。
resource "alicloud_hbr_server_backup_plan" "hbr_server_backup_plan" {
  for_each                    = { for s in local.ecs_hbr_flat : format("%s", s.instance_name) => s }
  ecs_server_backup_plan_name = each.value.ecs_server_backup_plan_name
  instance_id                 = alicloud_instance.instance[each.key].id
  retention                   = each.value.retention
  schedule                    = each.value.schedule
  detail {
    app_consistent        = lookup(each.value, "detail.app_consistent", true)
    snapshot_group        = lookup(each.value, "detail.snapshot_group", true)
    enable_fs_freeze      = lookup(each.value, "detail.enable_fs_freeze", false)
    pre_script_path       = lookup(each.value, "detail.pre_script_path", null)
    post_script_path      = lookup(each.value, "detail.post_script_path", null)
    timeout_in_seconds    = lookup(each.value, "detail.timeout_in_seconds", 30)
    disk_id_list          = lookup(each.value, "detail.disk_id_list", null)
    do_copy               = lookup(each.value, "detail.do_copy", false)
    destination_region_id = lookup(each.value, "detail.destination_region_id", null)
    destination_retention = lookup(each.value, "detail.destination_retention", null)
  }
  disabled                = each.value.disabled
  cross_account_type      = each.value.cross_account_type
  cross_account_user_id   = each.value.cross_account_user_id
  cross_account_role_name = each.value.cross_account_role_name
}
