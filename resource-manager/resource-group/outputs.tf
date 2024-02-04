output "resource_manager_resource_group_id" {
  value = { for i, resource_manager_resource_group in alicloud_resource_manager_resource_group.resource_manager_resource_group : i => resource_manager_resource_group.id }
}
