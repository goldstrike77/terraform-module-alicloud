output "route_table_id" {
  value = { for i, route_table in alicloud_route_table.route_table : i => route_table.id }
}
