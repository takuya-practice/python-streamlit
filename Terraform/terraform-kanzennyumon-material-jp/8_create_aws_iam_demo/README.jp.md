# 8. AWS IAMリソースを作成してみよう

S3のFull Accessポリシーを持ったIAM roleを作ります。その手順は、
1. AWS IAM Policyを作成し、S3のFull accessを許可する
2. AWS IAM Roleを作成し、１）のIAM PolicyをRoleに関連づける。


# 8.1 自分でコーディングする場合（Naiveアプローチ）
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy


[8.1_aws_iam/main.tf](8.1_aws_iam/main.tf)で、IAM PolicyとIAM roleを作成する
```sh
# IAM policyを作成
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
# IAM policyをIAM roleにバインド
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
# IAM Roleを作成
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
```


`terraform init`と`terraform apply` をすると、`8.1_aws_iam/main.tf`で定義されたAWS IAM Policy, IAM Roleリソースが作成されるのがわかる
```sh
Terraform will perform the following actions:

  # aws_iam_policy.s3_full_access will be created
  + resource "aws_iam_policy" "s3_full_access" {
      + arn         = (known after apply)
      + description = "s3_full_access"
      + id          = (known after apply)
      + name        = "s3_full_access"
      + path        = "/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # aws_iam_role.s3_full_access will be created
  + resource "aws_iam_role" "s3_full_access" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "s3_full_access_role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_iam_role_policy.s3_full_access_policy will be created
  + resource "aws_iam_role_policy" "s3_full_access_policy" {
      + id     = (known after apply)
      + name   = "s3_full_access_policy"
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + role   = "s3_full_access_role"
    }


Plan: 3 to add, 0 to change, 0 to destroy.
```

その後は、`terraform destroy`で削除しましょう。


# 8.2 Terraform Moduleを再利用する場合（Best Practice）

Refs:
- https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest
- https://github.com/terraform-aws-modules/terraform-aws-iam


[8.2_aws_iam_module/main.tf](8.2_aws_iam_module/main.tf)で、Remote Moduleを再利用してIAM PolicyとIAM roleを作成する

```sh
#########################################
# IAM policy
#########################################
# ref: https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-assumable-role/main.tf#L64-L85
module "s3_full_access_iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"　# <------ IAM policyのRemote Moduleを利用して作成

  name        = "s3-full-access"
  path        = "/"
  description = "s3-full-access"

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

data "aws_caller_identity" "this" {}

##########################################
# IAM assumable role with custom policies
##########################################
# ref: https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-assumable-role/main.tf#L32-L59
module "iam_assumable_role_custom" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role" # <------ IAM RoleのRemote Moduleを利用して作成

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
  ]

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = "s3-full-access-role"
  role_requires_mfa = false

  role_sts_externalid = "s3-full-access-role"

  custom_role_policy_arns = [
    module.s3_full_access_iam_policy.arn
  ]
}
```

`terraform init`と`terraform apply` をすると、`8.2_aws_iam_module/main.tf`で定義されたAWS IAM Policy, IAM Roleリソースが作成されるのがわかる
```sh
Terraform will perform the following actions:

  # module.iam_assumable_role_custom.aws_iam_role.this[0] will be created
  + resource "aws_iam_role" "this" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Condition = {
                          + StringEquals = {
                              + sts:ExternalId = "s3-full-access-role"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS     = "arn:aws:iam::266981300450:root"
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "s3-full-access-role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # module.iam_assumable_role_custom.aws_iam_role_policy_attachment.custom[0] will be created
  + resource "aws_iam_role_policy_attachment" "custom" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "s3-full-access-role"
    }

  # module.s3_full_access_iam_policy.aws_iam_policy.policy will be created
  + resource "aws_iam_policy" "policy" {
      + arn         = (known after apply)
      + description = "s3-full-access"
      + id          = (known after apply)
      + name        = "s3-full-access"
      + path        = "/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```


# 8.3 terraform initと.terraform/の解剖
`terraform init`をすると以下のアウトプットが表示されました。
```sh
Initializing modules...
Downloading terraform-aws-modules/iam/aws 3.7.0 for iam_assumable_role_custom...
- iam_assumable_role_custom in .terraform/modules/iam_assumable_role_custom/modules/iam-assumable-role
Downloading terraform-aws-modules/iam/aws 3.7.0 for s3_full_access_iam_policy...
- s3_full_access_iam_policy in .terraform/modules/s3_full_access_iam_policy/modules/iam-policy

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.70.0... # <------ TerraformがAWSというProviderのPluginsをLocalhost上にダウンロード

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

これは、TerraformがAWSというProviderを使って（TerraformはGCP、AzureのProviderもある）、AWSのリソースを作成できるようにPluginsなどをLocalhost上にダウンロードしていました。


また`terraform init`の後、`.terraform`というフォルダーが作成されているのがわかります。
```sh
$ pwd
terraform-kanzennyumon/8_create_aws_iam_demo/8.2_aws_iam_module

$ tree .terraform/ -d
.terraform/
├── modules
│   ├── iam_assumable_role_custom # <----- Terraform remote moduleを使うので、これがダウンロードされた
│   │   ├── examples
│   │   │   ├── iam-account
│   │   │   ├── iam-assumable-role
│   │   │   ├── iam-assumable-role-with-oidc
│   │   │   ├── iam-assumable-roles
│   │   │   ├── iam-assumable-roles-with-saml
│   │   │   ├── iam-group-complete
│   │   │   ├── iam-group-with-assumable-roles-policy
│   │   │   ├── iam-group-with-policies
│   │   │   ├── iam-policy
│   │   │   └── iam-user
│   │   └── modules
│   │       ├── iam-account
│   │       ├── iam-assumable-role
│   │       ├── iam-assumable-role-with-oidc
│   │       ├── iam-assumable-roles
│   │       ├── iam-assumable-roles-with-saml
│   │       ├── iam-group-with-assumable-roles-policy
│   │       ├── iam-group-with-policies
│   │       ├── iam-policy
│   │       └── iam-user
│   └── s3_full_access_iam_policy
│       ├── examples
│       │   ├── iam-account
│       │   ├── iam-assumable-role
│       │   ├── iam-assumable-role-with-oidc
│       │   ├── iam-assumable-roles
│       │   ├── iam-assumable-roles-with-saml
│       │   ├── iam-group-complete
│       │   ├── iam-group-with-assumable-roles-policy
│       │   ├── iam-group-with-policies
│       │   ├── iam-policy
│       │   └── iam-user
│       └── modules
│           ├── iam-account
│           ├── iam-assumable-role
│           ├── iam-assumable-role-with-oidc
│           ├── iam-assumable-roles
│           ├── iam-assumable-roles-with-saml
│           ├── iam-group-with-assumable-roles-policy
│           ├── iam-group-with-policies
│           ├── iam-policy
│           └── iam-user
└── plugins
    └── darwin_amd64
```