variable "bucket_a_module" {
  description = "The Invicton-Labs/secure-s3-bucket/aws module that was used to create bucket A."
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
}

variable "bucket_b_module" {
  description = "The Invicton-Labs/secure-s3-bucket/aws module that was used to create bucket B."
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
}

variable "replicate_a_to_b" {
  description = "Whether to replicate objects from bucket A to bucket B."
  type        = bool
}

variable "replicate_b_to_a" {
  description = "Whether to replicate objects from bucket B to bucket A."
  type        = bool
}

variable "a_to_b_rules" {
  description = "A list of rules for replicating objects from bucket A to bucket B, ordered by descending priority."
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
  description = "A list of rules for replicating objects from bucket B to bucket A, ordered by descending priority."
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
  a_to_b_rules = var.b_to_a_rules != null ? var.a_to_b_rules : []
  b_to_a_rules = var.b_to_a_rules != null ? var.b_to_a_rules : []
}
