module "at_least_one_rule_a_to_b" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.1"
  condition     = var.replicate_a_to_b == false || length(local.a_to_b_rules) > 0
  error_message = "If `replicate_a_to_b` is set to `true`, at least one element must be provided for `a_to_b_rules`."
}

module "at_least_one_rule_b_to_a" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.1"
  condition     = var.replicate_b_to_a == false || length(local.b_to_a_rules) > 0
  error_message = "If `replicate_b_to_a` is set to `true`, at least one element must be provided for `b_to_a_rules`."
}

module "assert_same_account" {
  source  = "Invicton-Labs/assertion/null"
  version = "~>0.2.1"
  depends_on = [
    module.at_least_one_rule_a_to_b,
    module.at_least_one_rule_b_to_a,
  ]
  condition     = var.bucket_a_module.account_id == var.bucket_b_module.account_id
  error_message = "Replication may only be configured with this module for two buckets in the same AWS account."
}
