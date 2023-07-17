resource "aws_dynamodb_table" "this" {
  name           = "urls"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  hash_key  = "shortURL"
  range_key = "urlId"

  # hash_key  = "UrlId"
  # range_key = "ShortURL"

  attribute {
    name = "shortURL"
    type = "S"
  }

  attribute {
    name = "urlId"
    type = "S"
  }

}

resource "aws_iam_policy" "this" {
  name        = "DynamoDBPolicyURLShorterer"
  description = "Policy for accessing the table in DynamoDB"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadWriteTable",
            "Effect": "Allow",
            "Action": [
              "dynamodb:Query",
              "dynamodb:PutItem"
            ],
            "Resource": "${aws_dynamodb_table.this.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = module.lambda.lambda_exec_role_name
  policy_arn = aws_iam_policy.this.arn
}
