# -----------------------------------------------------------------------------
# Computed Values
# -----------------------------------------------------------------------------

locals {
  # Directory opened by VS Code Web and passed to the AI agents.
  # Points at the cloned repository when one is configured, otherwise the
  # base directory itself.
  repo_url         = trimspace(data.coder_parameter.repo_url.value)
  base_dir         = data.coder_parameter.base_dir.value
  workspace_folder = try(module.git-clone-main[0].repo_dir, data.coder_parameter.base_dir.value)

  # VS Code Web extensions installed on first launch.
  vscode_extensions = [
    "Anthropic.claude-code",
    "neophack.git-graph-rs",
    "sst-dev.opencode",
    "github.vscode-github-actions",
  ]

  # VS Code Web machine settings applied on startup.
  # Copilot is a built-in extension of the VS Code Server and cannot be
  # uninstalled via the module, so it is suppressed with every known
  # setting instead.
  vscode_settings = {
    # Theme.
    "workbench.colorTheme" = "Dark Modern"

    # Skip the welcome / walkthrough page on startup.
    "workbench.startupEditor" = "none"

    # Disable all telemetry and experiments.
    "telemetry.telemetryLevel"              = "off"
    "telemetry.enableTelemetry"             = false
    "workbench.enableExperiments"           = false
    "redhat.telemetry.enabled"              = false
    "workbench.settings.showAISearchToggle" = false

    # Disable the chat UI entirely.
    "chat.disableAIFeatures"               = true
    "chat.enabled"                         = false
    "chat.commandCenter.enabled"           = false
    "chat.agent.enabled"                   = false
    "search.searchView.keywordSuggestions" = false

    # Disable Copilot for every language.
    "github.copilot.enable" = {
      "*"         = false
      "plaintext" = false
      "markdown"  = false
      "scminput"  = false
    }
    "github.copilot.editor.enableAutoCompletions"           = false
    "github.copilot.editor.enableCodeActions"               = false
    "github.copilot.nextEditSuggestions.enabled"            = false
    "github.copilot.nextEditSuggestions.fixes"              = false
    "github.copilot.renameSuggestions.triggerAutomatically" = false
    "github.copilot.chat.agent.autoFix"                     = false
    "github.copilot.chat.claudeAgent.enabled"               = false
    "github.copilot.chat.codesearch.enabled"                = false
    "github.copilot.chat.newWorkspaceCreation.enabled"      = false
    "github.copilot.chat.reviewSelection.enabled"           = false
    "github.copilot.chat.setupTests.enabled"                = false
    "github.copilot.chat.useProjectTemplates"               = false

    # Format on save.
    "editor.formatOnSave" = true
  }
}
