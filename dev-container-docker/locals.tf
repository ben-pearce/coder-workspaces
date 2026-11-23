# -----------------------------------------------------------------------------
# Computed Values
# -----------------------------------------------------------------------------

locals {
  additional_repo_urls  = try(compact(jsondecode(data.coder_parameter.additional_repo_urls.value)), [])
  devcontainer_repo_dir = try(module.git-clone-main[0].repo_dir, "")
}
