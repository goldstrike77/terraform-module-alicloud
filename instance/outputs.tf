output "instance_id" {
  value = { for i, instance in alicloud_instance.instance : i => instance.id }
}
