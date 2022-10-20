variable "bucket_a_module" {
  description = "The Kalepa/secure-s3-bucket/aws module that was used to create bucket A."
  type = object({
    name       = string
    region     = string
    account_id = number
    bucket = object({
      id  = string
      arn = string
    })
    kms_key_arn                      = string
    outbound_replication_policy_json = string
    inbound_replication_policy_json  = string
    complete                         = bool
  })
  validation {
    condition     = var.bucket_a_module != null
    error_message = "`bucket_a_module` may not be `null`."
  }
}

variable "bucket_b_module" {
  description = "The Kalepa/secure-s3-bucket/aws module that was used to create bucket B."
  type = object({
    name       = string
    region     = string
    account_id = number
    bucket = object({
      id  = string
      arn = string
    })
    kms_key_arn                      = string
    outbound_replication_policy_json = string
    inbound_replication_policy_json  = string
    complete                         = bool
  })
  validation {
    condition     = var.bucket_b_module != null
    error_message = "`bucket_b_module` may not be `null`."
  }
}

variable "replicate_a_to_b" {
  description = "Whether to replicate objects from bucket A to bucket B."
  type        = bool
  validation {
    condition     = var.replicate_a_to_b != null
    error_message = "`replicate_a_to_b` may not be `null`."
  }
}

variable "replicate_b_to_a" {
  description = "Whether to replicate objects from bucket B to bucket A."
  type        = bool
  validation {
    condition     = var.replicate_b_to_a != null
    error_message = "`replicate_b_to_a` may not be `null`."
  }
}

variable "a_to_b_rules" {
  description = "A list of rules for replicating objects from bucket A to bucket B, ordered by descending priority. If none are provided, it will default to replicating everything, including delete markers and replica modifications."
  type = list(object({
    id                          = string
    delete_marker_replication   = bool
    existing_object_replication = bool
    replica_modifications       = bool
    prefix                      = string
    tags                        = map(string)
    replication_time            = number
    event_threshold             = number
    storage_class               = string
  }))
  default = []
}

variable "b_to_a_rules" {
  description = "A list of rules for replicating objects from bucket B to bucket A, ordered by descending priority. If none are provided, it will default to replicating everything, including delete markers and replica modifications."
  type = list(object({
    id                          = string
    delete_marker_replication   = bool
    existing_object_replication = bool
    replica_modifications       = bool
    prefix                      = string
    tags                        = map(string)
    replication_time            = number
    event_threshold             = number
    storage_class               = string
  }))
  default = []
}

locals {
  default_rules = [
    {
      id                          = "everything"
      delete_marker_replication   = true
      existing_object_replication = false
      replica_modifications       = true
      prefix                      = null
      tags                        = null
      replication_time            = null
      event_threshold             = null
      storage_class               = null
    }
  ]
  a_to_b_rules = var.a_to_b_rules != null ? length(var.a_to_b_rules) > 0 ? var.a_to_b_rules : local.default_rules : local.default_rules
  b_to_a_rules = var.b_to_a_rules != null ? length(var.b_to_a_rules) > 0 ? var.b_to_a_rules : local.default_rules : local.default_rules
}
