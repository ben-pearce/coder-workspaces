# -----------------------------------------------------------------------------
# VS Code Web
# -----------------------------------------------------------------------------

# Purpose: Provide VS Code Server in the browser as the primary access method.
# Locals: local.workspace_folder, local.vscode_extensions, local.vscode_settings.
module "vscode-web" {
  count                   = data.coder_workspace.me.start_count
  source                  = "registry.coder.com/coder/vscode-web/coder"
  version                 = "1.6.2"
  agent_id                = coder_agent.main.id
  accept_license          = true
  disable_trust           = true
  folder                  = local.workspace_folder
  extensions              = local.vscode_extensions
  auto_install_extensions = true
  order                   = 0
  settings                = local.vscode_settings
}

# -----------------------------------------------------------------------------
# AI Agents
# -----------------------------------------------------------------------------

# Purpose: Install and configure the Claude Code CLI.
# Locals: local.workspace_folder.
module "claude-code" {
  count                   = data.coder_workspace.me.start_count
  source                  = "registry.coder.com/coder/claude-code/coder"
  version                 = "5.5.2"
  agent_id                = coder_agent.main.id
  workdir                 = local.workspace_folder == "" ? null : local.workspace_folder
  anthropic_api_key       = data.coder_parameter.anthropic_api_key.value
  claude_code_oauth_token = data.coder_parameter.claude_code_oauth_token.value
}

# Purpose: Install and configure the OpenCode CLI.
# Locals: local.workspace_folder.
module "opencode" {
  count     = data.coder_workspace.me.start_count
  source    = "registry.coder.com/coder-labs/opencode/coder"
  version   = "1.0.0"
  agent_id  = coder_agent.main.id
  workdir   = local.workspace_folder == "" ? null : local.workspace_folder
  auth_json = data.coder_parameter.opencode_auth_json.value
}
