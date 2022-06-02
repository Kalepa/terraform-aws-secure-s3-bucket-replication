data "aws_iam_policy_document" "s3_assume" {
  provider = aws.a
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "a_to_b" {
  count = var.replicate_a_to_b ? 1 : 0
  depends_on = [
    module.assert_same_account
  ]
  provider           = aws.b
  name               = "s3-replication-${md5("${var.bucket_a_module.bucket.id}-${var.bucket_b_module.bucket.id}")}"
  assume_role_policy = data.aws_iam_policy_document.s3_assume.json
}

resource "aws_iam_role_policy" "a_outbound" {
  count    = length(aws_iam_role.a_to_b)
  provider = aws.b
  name     = "from-${var.bucket_a_module.bucket.id}"
  role     = aws_iam_role.a_to_b[0].name
  policy   = var.bucket_a_module.outbound_replication_policy_json
}
resource "aws_iam_role_policy" "b_inbound" {
  count    = length(aws_iam_role.a_to_b)
  provider = aws.b
  name     = "to-${var.bucket_b_module.bucket.id}"
  role     = aws_iam_role.a_to_b[0].name
  policy   = var.bucket_b_module.inbound_replication_policy_json
}

resource "aws_iam_role" "b_to_a" {
  count = var.replicate_a_to_b ? 1 : 0
  depends_on = [
    module.assert_same_account
  ]
  provider           = aws.a
  name               = "s3-replication-${md5("${var.bucket_b_module.bucket.id}-${var.bucket_a_module.bucket.id}")}"
  assume_role_policy = data.aws_iam_policy_document.s3_assume.json
}

resource "aws_iam_role_policy" "b_outbound" {
  count    = length(aws_iam_role.b_to_a)
  provider = aws.a
  name     = "from-${var.bucket_b_module.bucket.id}"
  role     = aws_iam_role.b_to_a[0].name
  policy   = var.bucket_b_module.outbound_replication_policy_json
}
resource "aws_iam_role_policy" "a_inbound" {
  count    = length(aws_iam_role.b_to_a)
  provider = aws.a
  name     = "to-${var.bucket_a_module.bucket.id}"
  role     = aws_iam_role.b_to_a[0].name
  policy   = var.bucket_a_module.inbound_replication_policy_json
}
