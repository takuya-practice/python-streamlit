resource "aws_iam_policy" "s3_full_access" {
  name        = "s3_full_access"
  path        = "/"
  description = "s3_full_access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "s3_full_access_policy" {
  name = "s3_full_access_policy"
  role = aws_iam_role.s3_full_access.id

  # JSONをここでPasteすることも可能
  # policy = <<-EOF
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Action": [
  #         "ec2:Describe*"
  #       ],
  #       "Effect": "Allow",
  #       "Resource": "*"
  #     }
  #   ]
  # }
  # EOF

  # もしくわ、resource "aws_iam_policy"を作成してから使用することも可能
  policy = aws_iam_policy.s3_full_access.policy
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "s3_full_access" {
  name = "s3_full_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}