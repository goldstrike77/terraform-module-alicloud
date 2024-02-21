output "db_instance_id" {
  value = { for i, db_instance in alicloud_db_instance.db_instance : i => db_instance.id }
}
