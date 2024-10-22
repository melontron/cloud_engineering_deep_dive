resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}


module "github-runner" {
  source  = "philips-labs/github-runner/aws"
  version = "5.17.2"

  aws_region = local.main_region
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.network.*.id

  prefix = "gh-ci"

  github_app = {
    key_base64     = local.github_app_key
    id             = local.github_app_id
    webhook_secret = local.github_webhook_secret
  }

  webhook_lambda_zip                = "./src/build/webhook.zip"
  runner_binaries_syncer_lambda_zip = "./src/build/runner-binaries-syncer.zip"
  runners_lambda_zip                = "./src/build/runners.zip"
  enable_organization_runners = true
}