resource "aws_s3_bucket_replication_configuration" "a_to_b" {
  count    = var.replicate_a_to_b ? 1 : 0
  provider = aws.bucket_a
  depends_on = [
    module.assert_same_account,
    aws_iam_role_policy.a_outbound,
    aws_iam_role_policy.b_inbound,
  ]
  role   = aws_iam_role.a_to_b[0].arn
  bucket = var.bucket_a_module.bucket.id

  dynamic "rule" {
    for_each = var.a_to_b_rules
    content {
      id = rule.value.id
      // Rules are listed by descending priority, so the first rule should have the highest
      // priority number.
      priority = length(var.a_to_b_rules) - tonumber(rule.key)

      // If you don't want it to be enabled, don't include it in the list of rules
      status = "Enabled"

      delete_marker_replication {
        status = rule.value.delete_marker_replication == false ? "Disabled" : "Enabled"
      }

      dynamic "existing_object_replication" {
        for_each = rule.value.existing_object_replication == true ? [1] : []
        content {
          status = "Enabled"
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.replica_modifications == true || var.bucket_b_module.kms_key_arn != null ? [1] : []
        content {
          dynamic "replica_modifications" {
            for_each = rule.value.replica_modifications == true ? [1] : []
            content {
              status = "Enabled"
            }
          }
          sse_kms_encrypted_objects {
            status = var.bucket_b_module.kms_key_arn != null ? "Enabled" : "Disabled"
          }
        }
      }

      destination {
        bucket = var.bucket_b_module.bucket.arn
        dynamic "encryption_configuration" {
          for_each = var.bucket_b_module.kms_key_arn != null ? [1] : []
          content {
            replica_kms_key_id = var.bucket_b_module.kms_key_arn
          }
        }
        dynamic "metrics" {
          for_each = rule.value.event_threshold != null ? [1] : []
          content {
            status = "Enabled"
            event_threshold {
              minutes = rule.value.event_threshold
            }
          }
        }
        dynamic "replication_time" {
          for_each = rule.value.replication_time != null ? [1] : []
          content {
            status = "Enabled"
            time {
              minutes = rule.value.replication_time
            }
          }
        }
        storage_class = rule.value.storage_class
      }

      filter {
        // Include the prefix if it's not null and there are no tags
        prefix = rule.value.prefix == null ? null : (rule.value.tags == null ? rule.value.prefix : (length(rule.value.tags) == 0 ? rule.value.prefix : null))
        dynamic "tag" {
          // Include the tag if it's not null and there's only one of them and there's no prefix
          for_each = rule.value.tags == null ? [] : (length(rule.value.tags) == 1 && rule.value.prefix == null ? [1] : [])
          content {
            key   = keys(rule.value.tags)[0]
            value = values(rule.value.tags)[0]
          }
        }
        dynamic "and" {
          // Include the "and" if there's at least one tag AND (there's a prefix OR there are multiple tags)
          for_each = rule.value.tags == null ? [] : ((length(rule.value.tags) > 0 && rule.value.prefix != null) || length(rule.value.tags) > 1 ? [1] : [])
          content {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "b_to_a" {
  count    = var.replicate_b_to_a ? 1 : 0
  provider = aws.bucket_b
  depends_on = [
    module.assert_same_account,
    aws_iam_role_policy.b_outbound,
    aws_iam_role_policy.a_inbound,
  ]
  role   = aws_iam_role.b_to_a[0].arn
  bucket = var.bucket_b_module.bucket.id

  dynamic "rule" {
    for_each = var.b_to_a_rules
    content {
      id = rule.value.id
      // Rules are listed by descending priority, so the first rule should have the highest
      // priority number.
      priority = length(var.b_to_a_rules) - tonumber(rule.key)

      // If you don't want it to be enabled, don't include it in the list of rules
      status = "Enabled"

      delete_marker_replication {
        status = rule.value.delete_marker_replication == false ? "Disabled" : "Enabled"
      }

      dynamic "existing_object_replication" {
        for_each = rule.value.existing_object_replication == true ? [1] : []
        content {
          status = "Enabled"
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.replica_modifications == true || var.bucket_a_module.kms_key_arn != null ? [1] : []
        content {
          dynamic "replica_modifications" {
            for_each = rule.value.replica_modifications == true ? [1] : []
            content {
              status = "Enabled"
            }
          }
          sse_kms_encrypted_objects {
            status = var.bucket_a_module.kms_key_arn != null ? "Enabled" : "Disabled"
          }
        }
      }

      destination {
        bucket = var.bucket_a_module.bucket.arn
        dynamic "encryption_configuration" {
          for_each = var.bucket_a_module.kms_key_arn != null ? [1] : []
          content {
            replica_kms_key_id = var.bucket_a_module.kms_key_arn
          }
        }
        dynamic "metrics" {
          for_each = rule.value.event_threshold != null ? [1] : []
          content {
            status = "Enabled"
            event_threshold {
              minutes = rule.value.event_threshold
            }
          }
        }
        dynamic "replication_time" {
          for_each = rule.value.replication_time != null ? [1] : []
          content {
            status = "Enabled"
            time {
              minutes = rule.value.replication_time
            }
          }
        }
        storage_class = rule.value.storage_class
      }

      filter {
        // Include the prefix if it's not null and there are no tags
        prefix = rule.value.prefix == null ? null : (rule.value.tags == null ? rule.value.prefix : (length(rule.value.tags) == 0 ? rule.value.prefix : null))
        dynamic "tag" {
          // Include the tag if it's not null and there's only one of them and there's no prefix
          for_each = rule.value.tags == null ? [] : (length(rule.value.tags) == 1 && rule.value.prefix == null ? [1] : [])
          content {
            key   = keys(rule.value.tags)[0]
            value = values(rule.value.tags)[0]
          }
        }
        dynamic "and" {
          // Include the "and" if there's at least one tag AND (there's a prefix OR there are multiple tags)
          for_each = rule.value.tags == null ? [] : ((length(rule.value.tags) > 0 && rule.value.prefix != null) || length(rule.value.tags) > 1 ? [1] : [])
          content {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }
      }
    }
  }
}
