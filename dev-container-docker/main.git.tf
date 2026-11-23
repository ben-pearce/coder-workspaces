# -----------------------------------------------------------------------------
# Git Configuration
# -----------------------------------------------------------------------------

# Purpose: Install a Coder-managed SSH key and enable signed commits.
resource "coder_script" "git_commit_signing" {
  count        = data.coder_workspace.me.start_count
  agent_id     = coder_agent.main.id
  display_name = "Git commit signing"
  icon         = "/icon/git.svg"
  run_on_start = true
  script       = file("${path.module}/scripts/git-commit-signing.sh")
}

# Purpose: Configure the global git user identity for the workspace owner.
module "git-config" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/git-config/coder"
  version  = "1.0.35"
  agent_id = coder_agent.main.id
}

# -----------------------------------------------------------------------------
# Git Repositories
# -----------------------------------------------------------------------------

# Purpose: Clone the main project repository that provides the devcontainer.
module "git-clone-main" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/git-clone/coder"
  version  = "2.0.5"
  agent_id = coder_agent.main.id
  url      = data.coder_parameter.repo_url.value
  base_dir = data.coder_parameter.base_dir.value

  pre_clone_script = file("${path.module}/scripts/ssh-config.sh")
}

# Purpose: Clone additional repositories after the main clone sets up SSH.
# Locals: local.additional_repo_urls.
module "git-clone-additional" {
  count    = data.coder_workspace.me.start_count * length(local.additional_repo_urls)
  source   = "registry.coder.com/coder/git-clone/coder"
  version  = "2.0.5"
  agent_id = coder_agent.main.id
  url      = local.additional_repo_urls[count.index]
  base_dir = data.coder_parameter.base_dir.value

  depends_on = [module.git-clone-main]
}
