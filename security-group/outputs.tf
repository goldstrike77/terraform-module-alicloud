output "security_group_id" {
  value = { for i, security_group in alicloud_security_group.security_group: i => security_group.id }
}