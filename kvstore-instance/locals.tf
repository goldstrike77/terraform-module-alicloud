# 将通过变量传入的元数据映射投影到每个变量都有单独元素的集合。
locals {
  kvstore_flat = flatten([
    for s in var.res_spec.kvstore[*] : [
      for t in s.db_instance_name : {
        name = t
        password = lookup(s, "password", null)
        port = lookup(s, "port", "6379")
        public = lookup(s, "public", false)
        instance_class = lookup(s, "instance_class", "redis.master.small.default")
        capacity = lookup(s, "capacity", null)
        zone_id = s.zone_id
        secondary_zone_id = lookup(s, "secondary_zone_id", null)
        payment_type = lookup(s, "payment_type", "PrePaid")
        period = lookup(s, "period", 1)
        auto_renew = lookup(s, "auto_renew", false)
        auto_renew_period = lookup(s, "auto_renew_period", 1)
        instance_type  = lookup(s, "instance_type", "Redis")
        vswitch_name = s.vswitch_name
        engine_version = lookup(s, "engine_version", "4.0")
        tags = lookup(s, "tags", {})
        security_ips = lookup(s, "security_ips", "127.0.0.1")
        security_group_name = lookup(s, "security_group_name", "")
        vpc_auth_mode = lookup(s, "vpc_auth_mode", "Open")
        config = lookup(s, "config", {})
        maintain_start_time = lookup(s, "maintain_start_time", "16:00Z")
        maintain_end_time = lookup(s, "maintain_end_time", "20:00Z")
#        ssl_enable = lookup(s, "ssl_enable", "Disable")
        db_audit = lookup(s, "db_audit", false)
        retention = lookup(s, "retention", 7)
        backup_period =  lookup(s, "backup_period", ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
        backup_time = lookup(s, "backup_time", "20:00Z-21:00Z")
      }
    ]
  ])
}