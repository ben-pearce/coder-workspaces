# -----------------------------------------------------------------------------
# Workspace Data
# -----------------------------------------------------------------------------

# Purpose: Read the provisioner architecture so the agent matches the host.
data "coder_provisioner" "me" {}

# Purpose: Read the current workspace id, name, and start count.
data "coder_workspace" "me" {}

# Purpose: Read the workspace owner identity used for naming and labels.
data "coder_workspace_owner" "me" {}

# -----------------------------------------------------------------------------
# Agent
# -----------------------------------------------------------------------------

# Purpose: Define the workspace agent, its lifecycle scripts, and resource metadata.
resource "coder_agent" "main" {
  arch            = data.coder_provisioner.me.arch
  os              = "linux"
  startup_script  = file("${path.module}/scripts/startup.sh")
  shutdown_script = file("${path.module}/scripts/shutdown.sh")

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    script       = file("${path.module}/scripts/metadata-load-average.sh")
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = file("${path.module}/scripts/metadata-swap-usage.sh")
    interval     = 10
    timeout      = 1
  }
}
