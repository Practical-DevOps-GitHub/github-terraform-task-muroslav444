provider "github" {
  token = var.github_token
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

resource "github_branch_default" "develop" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch
}

resource "github_branch_protection" "main" {
  repository = github_repository.repo.name
  branch     = "main"
  enforce_admins = true
}

resource "github_branch_protection" "develop" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch
  require_pull_request_reviews {
    dismiss_stale_reviews     = true
    require_code_owner_reviews = false
    required_approving_review_count = 2
  }
}

resource "github_repository_collaborator" "softservedata" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "pull"
}

resource "github_file" "pull_request_template" {
  repository = github_repository.repo.name
  file_path  = ".github/pull_request_template.md"
  content    = <<EOF
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
  plaintext_value = var.github_token
}

# Replace the webhook URL with your Discord webhook URL
resource "github_repository_webhook" "discord_webhook" {
  repository     = github_repository.repo.name
  name           = "discord"
  active         = true
  events         = ["pull_request"]
  configuration = {
    url          = "https://discord.com/api/webhooks/1131582221589942342/QPu0CLB0XO-QMDI31JyHHX72YuGoILhZK9Z_aJTpKSpyIi0eDzMYPkSQ0FGHM0arwv2_"
    content_type = "json"
  }
}

# Variables
variable "github_token" {
  description = "GitHub Personal Access Token with Full control of private repositories, Full control of orgs and teams, and read and write org projects"
}

variable "ssh_public_key" {
  description = "SSH public key to be used for the DEPLOY_KEY"
}
