resource "aws_apprunner_auto_scaling_configuration_version" "hello" {
  auto_scaling_configuration_name = "${var.environment}-hello"
  # scale between 1-5 containers
  min_size = 1
  max_size = 5

  tags = {
    Name           = "demo_auto_scaling_app_runner"
    Environment    = "${var.environment}"
    Provisioned_by = "Terraform"
  }
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "my-apprunner-vpc-connector-${var.environment}"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.app-runner-sg.id]
}


resource "time_sleep" "wait_app_runner_iam_role" {
  depends_on      = [aws_iam_role.app_runner_role]
  create_duration = "60s"
}

resource "aws_apprunner_service" "hello" {
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.hello.arn

  service_name = "hello-app-runner-${var.environment}"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8000"
      }

      image_identifier      = var.image_identifier
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_role.arn
    }

    auto_deployments_enabled = true
  }

  health_check_configuration {
    healthy_threshold   = 1
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = {
    Name           = "app_runner_service"
    Environment    = "${var.environment}"
    Provisioned_by = "Terraform"
  }

  depends_on = [
    aws_apprunner_auto_scaling_configuration_version.hello,
    time_sleep.wait_app_runner_iam_role
  ]
}


resource "aws_amplify_app" "hello_amplify_app" {
  name       = "hello-runner-${var.environment}"
  repository = "https://github.com/ExitoLab/amplify_example_static-webhosting"

  access_token             = var.access_token
  enable_branch_auto_build = true

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    Name           = "aws_amplify_example"
    Environment    = "${var.environment}"
    Provisioned_by = "Terraform"
  }
}

resource "aws_amplify_branch" "amplify_branch" {
  app_id      = aws_amplify_app.hello_amplify_app.id
  branch_name = "main"
}

# Define your existing Route 53 zone
data "aws_route53_zone" "example_com" {
  name = var.aws_apprunner_domain
}



# # Create a DNS record for your custom domain pointing to the App Runner service
# resource "aws_route53_record" "app_runner_custom_domain" {
#   zone_id = data.aws_route53_zone.example_com.zone_id
#   name    = "${var.environment}-apprunner.${var.aws_apprunner_domain}"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_apprunner_service.hello.default_domain_name]
# }

# Get the SSL certificate for your custom domain
# data "aws_acm_certificate" "app_runner_domain" {
#   domain   = var.aws_apprunner_domain
#   statuses = ["ISSUED"]
# }


# Attach an SSL certificate to the App Runner service
# resource "aws_apprunner_custom_domain_association" "domain_association" {
#   service_arn = aws_apprunner_service.hello.arn
#   domain_name = var.aws_apprunner_domain
# }

# # Associate the domain name with the App Runner service.
# resource "aws_route53_record" "dns_target" {
#   allow_overwrite = true
#   name            = var.aws_apprunner_domain
#   records         = [aws_apprunner_custom_domain_association.domain_association.dns_target]
#   ttl             = 3600
#   type            = "CNAME"
#   zone_id         = data.aws_route53_zone.example_com.zone_id
# }
