output "oss_bucket_id" {
  value = { for i, oss_bucket in alicloud_oss_bucket.oss_bucket : i => oss_bucket.id }
}
