output "vpc_peer_connection_id" {
  value = { for i, vpc_peer_connection in alicloud_vpc_peer_connection.vpc_peer_connection : i => vpc_peer_connection.id }
}
