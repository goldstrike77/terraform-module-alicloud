output "vpc_id" {
  value = { for i, vpc in alicloud_vpc.vpc: i => vpc.id }
}