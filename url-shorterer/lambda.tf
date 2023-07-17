module "lambda" {
  source = "github.com/zikster3262/terraform-aws-modules/lambda"

  lambda_inputs = {
    name    = "lamba"
    handler = "index.handler"
    runtime = "nodejs16.x"
    timeout = 10
  }

  archive_file_inputs = {
    archive_type     = "zip"
    source_dir       = "${path.module}/lambda"
    output_path      = "${path.module}/lambda/lambda.zip"
    output_file_mode = "0666"
  }

  environment_variables = {
    DYNAMO_TABLE = aws_dynamodb_table.this.name
    API_GW       = aws_apigatewayv2_api.api-gw.api_endpoint
  }
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api-gw.execution_arn}/*/*"
  depends_on    = [module.lambda]
}

