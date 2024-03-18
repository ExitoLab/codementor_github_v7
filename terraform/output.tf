output "apprunner_service_hello" {
  value = aws_apprunner_service.hello
}

output "amplify_app_id" {
  value = aws_amplify_app.hello_amplify_app.id
}

