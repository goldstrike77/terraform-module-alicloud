output "nat_gateway_id" {
  value = { for i, nat_gateway in alicloud_nat_gateway.nat_gateway : i => nat_gateway.id }
}
