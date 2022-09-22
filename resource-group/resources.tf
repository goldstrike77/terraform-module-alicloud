# 创建资源组。
resource "alicloud_resource_manager_resource_group" "resource_group" {
  resource_group_name = var.res_spec.rg.name
  display_name = var.res_spec.rg.display_name
}