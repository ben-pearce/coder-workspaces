# -----------------------------------------------------------------------------
# Workspace Parameters
# -----------------------------------------------------------------------------

# Purpose: Optionally clone a repository into the base directory on start.
data "coder_parameter" "repo_url" {
  type         = "string"
  name         = "repo_url"
  display_name = "Project Repository"
  description  = <<-EOT
    URL of the Git repository to clone into the base directory.

    Leave empty to start with a clean workspace and clone repositories
    manually.
  EOT
  mutable      = true
  default      = ""
}

# Purpose: Set the base directory where the repository is cloned.
data "coder_parameter" "base_dir" {
  type         = "string"
  name         = "base_dir"
  display_name = "Base Directory"
  description  = <<-EOT
    Base directory into which the repository is cloned.

    Defaults to /home/coder/workspace. Change it to relocate cloned
    repositories for this workspace.

    Use an absolute path. Paths like ~ or $HOME are not expanded.
  EOT
  mutable      = true
  default      = "/home/coder/workspace"
}

# Purpose: Authenticate Claude Code with an Anthropic API key.
data "coder_parameter" "anthropic_api_key" {
  type         = "string"
  name         = "anthropic_api_key"
  display_name = "Anthropic API Key"
  description  = <<-EOT
    API key used to authenticate Claude Code with the Anthropic API.

    Leave empty to authenticate interactively with `claude` on first use,
    or with `claude setup-token` via the OAuth token parameter.
  EOT
  mutable      = true
  default      = ""
}

# Purpose: Authenticate Claude Code with a Claude.ai OAuth token.
data "coder_parameter" "claude_code_oauth_token" {
  type         = "string"
  name         = "claude_code_oauth_token"
  display_name = "Claude Code OAuth Token"
  description  = <<-EOT
    OAuth token used to authenticate Claude Code with a Claude.ai account.

    Generate one locally with `claude setup-token`. Leave empty to
    authenticate interactively or with the API key parameter.
  EOT
  mutable      = true
  default      = ""
}

# Purpose: Authenticate OpenCode with exported credentials.
data "coder_parameter" "opencode_auth_json" {
  type         = "string"
  name         = "opencode_auth_json"
  display_name = "OpenCode Auth JSON"
  description  = <<-EOT
    OpenCode credentials in the JSON array format printed by `opencode auth export`.

    Leave empty to authenticate interactively with `opencode auth login`
    on first use.
  EOT
  mutable      = true
  default      = ""
}
