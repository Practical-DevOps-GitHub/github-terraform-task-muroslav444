terraform {
  required_providers {
    github = {
      source = "hashicorp/github"
    }
  }
}

provider "github" {
  organization = "Practical-DevOps-GitHub/github-terraform-task-muroslav444"
  token = var.github_token
}

resource "github_repository" "repo" {
  name = "github-terraform-task-muroslav444"
  description = "This is my GitHub repository."
  visibility = "private"
}

resource "github_branch_protection" "main" {
  repository = github_repository.repo.name
  branch = "main"
  enforce_admins = true
  require_pull_request_reviews = true
  required_review_count = 2
}

resource "github_branch_protection" "develop" {
  repository = github_repository.repo.name
  branch = "develop"
  enforce_admins = true
  require_pull_request_reviews = true
  required_review_count = 2
}

resource "github_collaborator" "softservedata" {
  repository = github_repository.repo.name
  user = "softservedata"
  permissions = ["pull", "push", "admin"]
}

resource "github_pull_request_template" "pull_request_template" {
  repository = github_repository.repo.name
  path = ".github/pull_request_template.md"
  content = <<EOF
# Pull Request Template

## Describe your changes

Please describe your changes in detail.

## Issue ticket number and link

Please provide the issue ticket number and link.

## Checklist before requesting a review

* I have performed a self-review of my code.
* If it is a core feature, I have added thorough tests.
* Do we need to implement analytics?
* Will this be part of a product update? If yes, please write one phrase about this update.
EOF
}

resource "github_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title = "DEPLOY_KEY"
  key = file("~/.ssh/id_rsa.pub")
}

resource "github_integration" "discord" {
  repository = github_repository.repo.name
  integration_id = "discord"
  configuration = {
    webhook_url = "https://discord.com/api/webhooks/1131582221589942342/QPu0CLB0XO-QMDI31JyHHX72YuGoILhZK9Z_aJTpKSpyIi0eDzMYPkSQ0FGHM0arwv2_"
    events = ["pull_request"]
  }
}

resource "github_actions_secret" "pat" {
  repository = github_repository.repo.name
  secret_name = "PAT"
  secret_value = var.pat
}

variable "github_token" {
  type = string
}

variable "pat" {
  type = string
}

output "terraform_code" {
  value = file("main.tf")
}
