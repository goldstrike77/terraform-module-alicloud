output "vswitch_id" {
  value = { for i, vswitch in alicloud_vswitch.vswitch: i => vswitch.id }
}