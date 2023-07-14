resource "aws_apigatewayv2_api" "api-gw" {
  name          = "api-gw"
  protocol_type = "HTTP"
  version       = "1.0"
}

resource "aws_apigatewayv2_integration" "api-gw" {
  api_id             = aws_apigatewayv2_api.api-gw.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  connection_type    = "INTERNET"
  integration_uri    = module.lambda.invoke_arn
  depends_on         = [module.lambda]
}

resource "aws_apigatewayv2_route" "api-gw" {
  api_id     = aws_apigatewayv2_api.api-gw.id
  route_key  = "POST /"
  depends_on = [aws_apigatewayv2_api.api-gw]
  target     = "integrations/${aws_apigatewayv2_integration.api-gw.id}"
}

resource "aws_apigatewayv2_route" "api-types" {
  api_id     = aws_apigatewayv2_api.api-gw.id
  route_key  = "GET /{id}"
  depends_on = [aws_apigatewayv2_api.api-gw]
  target     = "integrations/${aws_apigatewayv2_integration.api-gw.id}"
}

resource "aws_cloudwatch_log_group" "api-logs" {
  name              = "/aws/api-gw/magic"
  retention_in_days = 30
}

resource "aws_apigatewayv2_stage" "api-gw" {
  api_id      = aws_apigatewayv2_api.api-gw.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-logs.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  depends_on = [aws_apigatewayv2_api.api-gw]
}

output "api-gw-url" {
  value = aws_apigatewayv2_api.api-gw.api_endpoint
}

