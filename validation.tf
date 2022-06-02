module "assert_same_account" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.1"
  condition     = var.bucket_a_module.account_id == var.bucket_b_module.account_id
  error_message = "Replication may only be configured with this module for two buckets in the same AWS account."
}
