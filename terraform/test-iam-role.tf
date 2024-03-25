resource "aws_iam_openid_connect_provider" "example_oidc_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

resource "aws_iam_role" "example_role" {
  name = "example-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.example_oidc_provider.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${aws_iam_openid_connect_provider.example_oidc_provider.url}:sub" : "user@example.com" # Replace with your desired sub claim value
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "example_policy" {
  name        = "example-policy"
  description = "Allows access to Secrets Manager and a specific resource"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "your-custom-resource-action", # Replace with your desired resource action
        "Resource" : "arn:aws:your-resource-arn"  # Replace with your desired resource ARN
      },
      {
        "Effect" : "Allow",
        "Action" : "rds-db:connect",
        "Resource" : "arn:aws:rds:region:account-id:db:db-instance-name/db-user" # Replace with your RDS DB instance ARN and DB user
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}
