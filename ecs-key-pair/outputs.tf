output "ecs_key_pair_id" {
  value = { for i, ecs_key_pair in alicloud_ecs_key_pair.ecs_key_pair : i => ecs_key_pair.id }
}
