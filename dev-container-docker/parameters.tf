# -----------------------------------------------------------------------------
# Workspace Parameters
# -----------------------------------------------------------------------------

# Purpose: Select the main project repository that provides the devcontainer.
data "coder_parameter" "repo_url" {
  type         = "string"
  name         = "repo_url"
  display_name = "Project Repository"
  description  = <<-EOT
    URL of the main Git repository to clone into the base directory.

    The repository must contain a devcontainer.json that defines the
    development environment for the workspace.
  EOT
  mutable      = true
}

# Purpose: Set the base directory where every repository is cloned.
data "coder_parameter" "base_dir" {
  type         = "string"
  name         = "base_dir"
  display_name = "Base Directory"
  description  = <<-EOT
    Base directory into which every repository is cloned.

    Defaults to ~/project. Change it to relocate all cloned repositories
    for this workspace.
  EOT
  mutable      = true
  default      = "~/project"
}

# Purpose: Select additional repositories to clone alongside the main one.
data "coder_parameter" "additional_repo_urls" {
  type         = "list(string)"
  name         = "additional_repo_urls"
  display_name = "Additional Repositories"
  description  = <<-EOT
    URLs of additional repositories to clone into the base directory.

    Each repository is cloned alongside the project repository, in order.
  EOT
  mutable      = true
}
