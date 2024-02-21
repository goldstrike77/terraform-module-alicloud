output "kvstore_instance_id" {
  value = { for i, kvstore_instance in alicloud_kvstore_instance.kvstore_instance : i => kvstore_instance.id }
}
