# Terraform AWS Replicated Secure Bucket

This module configures uni-directional or bi-directional replication between two S3 buckets that were created using the [Invicton-Labs/secure-s3-bucket/aws](https://registry.terraform.io/modules/Invicton-Labs/secure-s3-bucket/aws/latest) module.

At this time, it only supports configuring replication between two buckets that were created in the same AWS account. This is because cross-account replication requires setting specific S3 bucket policies, which must be set outside of the scope of these modules.
