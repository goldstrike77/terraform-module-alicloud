output "vpc_ipv4_cidr_block_id" {
  value = { for i, vpc_ipv4_cidr_block in alicloud_vpc_ipv4_cidr_block.vpc_ipv4_cidr_block : i => vpc_ipv4_cidr_block.id }
}
