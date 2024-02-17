output "bastionhost_instance_id" {
  value = { for i, bastionhost_instance in alicloud_bastionhost_instance.bastionhost_instance : i => bastionhost_instance.id }
}
