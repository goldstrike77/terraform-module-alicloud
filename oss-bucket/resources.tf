# 获取存储桶全局命名随时数。
resource "random_string" "string" {
  for_each    = { for s in local.oss_bucket_flat : format("%s", s.bucket) => s }
  length      = 8
  lower       = true
  numeric     = true
  special     = false
  upper       = false
  min_numeric = 2
  keepers = {
    seed = each.key
  }
}

# 创建存储桶。
resource "alicloud_oss_bucket" "oss_bucket" {
  for_each = { for s in local.oss_bucket_flat : format("%s", s.bucket) => s }
  bucket   = "${each.key}-${random_string.string[each.key].result}"
  acl      = each.value.acl
  dynamic "cors_rule" {
    for_each = each.value.cors_rule == {} ? [] : [1]
    content {
      allowed_headers = lookup(each.value.cors_rule, "allowed_headers", null)
      allowed_methods = lookup(each.value.cors_rule, "allowed_methods", "GET")
      allowed_origins = lookup(each.value.cors_rule, "allowed_origins", null)
      expose_headers  = lookup(each.value.cors_rule, "expose_headers", null)
      max_age_seconds = lookup(each.value.cors_rule, "max_age_seconds", null)
    }
  }
  dynamic "website" {
    for_each = each.value.website == {} ? [] : [1]
    content {
      index_document = lookup(each.value.website, "index_document", "index.html")
      error_document = lookup(each.value.website, "error_document", "error.html")
    }
  }
  dynamic "logging" {
    for_each = each.value.logging == {} ? [] : [1]
    content {
      target_bucket = each.value.logging.target_bucket
      target_prefix = lookup(each.value.logging, "target_prefix", "logs/")
    }
  }
  dynamic "referer_config" {
    for_each = each.value.referer_config == {} ? [] : [1]
    content {
      allow_empty = lookup(each.value.referer_config, "allow_empty", false)
      referers    = lookup(each.value.referer_config, "referers", [])
    }
  }
  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rule == {} ? [] : [1]
    content {
      id      = lookup(each.value.lifecycle_rule, "id", null)
      prefix  = lookup(each.value.lifecycle_rule, "prefix", null)
      enabled = lookup(each.value.lifecycle_rule, "enabled", true)
      dynamic "expiration" {
        for_each = each.value.lifecycle_rule.expiration == {} ? [] : [1]
        content {
          date                         = lookup(each.value.lifecycle_rule.expiration, "date", null)
          days                         = lookup(each.value.lifecycle_rule.expiration, "days", null)
          created_before_date          = lookup(each.value.lifecycle_rule.expiration, "created_before_date", null)
          expired_object_delete_marker = lookup(each.value.lifecycle_rule.expiration, "expired_object_delete_marker", null)
        }
      }
      dynamic "transitions" {
        for_each = each.value.lifecycle_rule.transitions == {} ? [] : [1]
        content {
          created_before_date      = lookup(each.value.lifecycle_rule.transitions, "created_before_date", null)
          days                     = lookup(each.value.lifecycle_rule.transitions, "days", null)
          storage_class            = lookup(each.value.lifecycle_rule.transitions, "storage_class", "Archive")
          is_access_time           = lookup(each.value.lifecycle_rule.transitions, "is_access_time", false)
          return_to_std_when_visit = lookup(each.value.lifecycle_rule.transitions, "return_to_std_when_visit", false)
        }
      }
      dynamic "abort_multipart_upload" {
        for_each = each.value.lifecycle_rule.abort_multipart_upload == {} ? [] : [1]
        content {
          created_before_date = lookup(each.value.lifecycle_rule.abort_multipart_upload, "created_before_date", null)
          days                = lookup(each.value.lifecycle_rule.abort_multipart_upload, "days", null)
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = each.value.lifecycle_rule.noncurrent_version_expiration == {} ? [] : [1]
        content {
          days = lookup(each.value.lifecycle_rule.noncurrent_version_expiration, "days", 180)
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = each.value.lifecycle_rule.noncurrent_version_transition == {} ? [] : [1]
        content {
          days                     = lookup(each.value.lifecycle_rule.noncurrent_version_transition, "days", 180)
          storage_class            = lookup(each.value.lifecycle_rule.noncurrent_version_transition, "storage_class", "Archive")
          is_access_time           = lookup(each.value.lifecycle_rule.noncurrent_version_transition, "is_access_time", false)
          return_to_std_when_visit = lookup(each.value.lifecycle_rule.noncurrent_version_transition, "return_to_std_when_visit", false)
        }
      }
    }
  }
  policy          = each.value.policy
  storage_class   = each.value.storage_class
  redundancy_type = each.value.redundancy_type
  dynamic "server_side_encryption_rule" {
    for_each = each.value.server_side_encryption_rule == {} ? [] : [1]
    content {
      sse_algorithm     = lookup(each.value.server_side_encryption_rule, "sse_algorithm", "KMS")
      kms_master_key_id = lookup(each.value.server_side_encryption_rule, "kms_master_key_id", null)
    }
  }
  tags = merge(var.tags, each.value.tags)
  versioning {
    status = each.value.versioning
  }
  force_destroy = each.value.force_destroy
  transfer_acceleration {
    enabled = each.value.transfer_acceleration
  }
  lifecycle_rule_allow_same_action_overlap = each.value.lifecycle_rule_allow_same_action_overlap
  access_monitor {
    status = each.value.access_monitor
  }
}
