# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  oss_bucket_flat = flatten([
    for s in var.resources : [
      for t in s.oss_bucket : {
        bucket                                   = t.bucket
        acl                                      = lookup(t, "acl", "private")
        cors_rule                                = lookup(t, "cors_rule", {})
        website                                  = lookup(t, "website", {})
        logging                                  = lookup(t, "logging", {})
        referer_config                           = lookup(t, "referer_config", {})
        lifecycle_rule                           = lookup(t, "lifecycle_rule", {})
        policy                                   = lookup(t, "policy", null)
        storage_class                            = title(lookup(t, "storage_class", "Standard"))
        redundancy_type                          = lookup(t, "redundancy_type", "LRS")
        server_side_encryption_rule              = lookup(t, "server_side_encryption_rule", {})
        tags                                     = lookup(t, "tags", {})
        versioning                               = title(lookup(t, "versioning", "Suspended"))
        force_destroy                            = lookup(t, "force_destroy", false)
        transfer_acceleration                    = lookup(t, "transfer_acceleration", false)
        lifecycle_rule_allow_same_action_overlap = lookup(t, "lifecycle_rule_allow_same_action_overlap", false)
        access_monitor                           = title(lookup(t, "access_monitor", "Enabled"))
      }
    ] if can(s.oss_bucket)
  ])
}
