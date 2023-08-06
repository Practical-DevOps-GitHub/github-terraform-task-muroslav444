provider "github" {
  token = "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"  
}

resource "github_repository" "repo" {
  name        = "github-terraform-task-muroslav444"  
  description = "Your repository description"  
  visibility  = "private"  
}

resource "github_branch" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_branch" "main" {
  repository = github_repository.repo.name
  branch     = "main"
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch
}

resource "github_branch_protection_rule" "main" {
  repository = github_repository.repo.name
  pattern    = "main"
  enforcement_level = "enforce"
  require_code_owner_reviews = false
}

resource "github_branch_protection_rule" "develop" {
  repository = github_repository.repo.name
  pattern    = "develop"
  enforcement_level = "enforce"
  require_code_owner_reviews = false

  required_pull_request_reviews {
    dismissal_restrictions {
      users = ["*"]
    }
    required_approving_review_count = 2
  }
}

resource "github_repository_collaborator" "softservedata" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "pull"
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.repo.name
  file_path  = ".github/pull_request_template.md"
  content    = <<-EOF
    Describe your changes

    Issue ticket number and link

    Checklist before requesting a review
    - [ ] I have performed a self-review of my code
    - [ ] If it is a core feature, I have added thorough tests
    - [ ] Do we need to implement analytics?
    - [ ] Will this be part of a product update? If yes, please write one phrase about this update
  EOF
}

resource "github_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = var.ssh_public_key  # Provide your public SSH key here
  read_only  = true
}

resource "github_actions_secret" "pat_secret" {
  repository = github_repository.repo.name
  secret_name = "PAT"
  plaintext_value = "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"  # Replace with your GitHub Personal Access Token (PAT)
}

resource "github_repository_webhook" "discord_webhook" {
  repository     = github_repository.repo.name
  name           = "discord"
  active         = true
  events         = ["pull_request"]
  
  configuration {
    url          = "https://discord.com/api/webhooks/1131582221589942342/QPu0CLB0XO-QMDI31JyHHX72YuGoILhZK9Z_aJTpKSpyIi0eDzMYPkSQ0FGHM0arwv2_"  # Replace with your Discord webhook URL
    content_type = "json"
  }
}
