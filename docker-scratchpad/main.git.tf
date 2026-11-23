# -----------------------------------------------------------------------------
# Git Configuration
# -----------------------------------------------------------------------------

# Purpose: Set up permissive SSH options for cloning over SSH.
resource "coder_script" "ssh_config" {
  count        = data.coder_workspace.me.start_count
  agent_id     = coder_agent.main.id
  display_name = "SSH config"
  icon         = "/icon/terminal.svg"
  run_on_start = true
  script       = file("${path.module}/scripts/ssh-config.sh")
}

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

# Purpose: Clone the project repository when a URL is configured.
module "git-clone-main" {
  count    = local.repo_url != "" ? data.coder_workspace.me.start_count : 0
  source   = "registry.coder.com/coder/git-clone/coder"
  version  = "2.0.5"
  agent_id = coder_agent.main.id
  url      = local.repo_url
  base_dir = local.base_dir

  pre_clone_script = file("${path.module}/scripts/ssh-config.sh")
}
