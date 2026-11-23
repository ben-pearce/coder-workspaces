# -----------------------------------------------------------------------------
# Terraform Requirements
# -----------------------------------------------------------------------------

# Purpose: Declare the Coder and Docker providers used by this template.
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "2.20.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }
}
