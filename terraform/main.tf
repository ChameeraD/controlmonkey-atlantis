terraform {
  required_version = ">= 1.5.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "project_name" {
  description = "Project or service name used to build labels."
  type        = string
  default     = "controlmonkey-sample"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "password_length" {
  description = "Length for generated password."
  type        = number
  default     = 20
  validation {
    condition     = var.password_length >= 12 && var.password_length <= 64
    error_message = "password_length must be between 12 and 64."
  }
}

variable "tags" {
  description = "User-provided tags to merge into common tags."
  type        = map(string)
  default = {
    owner      = "example"
    managed-by = "terraform"
  }
}

locals {
  name_prefix = lower(format("%s-%s", var.project_name, var.environment))
  common_tags = merge(
    var.tags,
    {
      project = var.project_name
      env     = var.environment
    }
  )
}

# Generate a readable service name component like "otter-panda"
resource "random_pet" "service" {
  length    = 2
  separator = "-"
}

# Create a strong password example (not used anywhere, just demonstration)
resource "random_password" "service" {
  length           = var.password_length
  special          = true
  override_special = "!@#$%&*()-_=+[]{}"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

# Produce a short hex identifier that stays stable as long as keepers don't change
resource "random_id" "artifact" {
  byte_length = 4
  keepers = {
    prefix = local.name_prefix
  }
}

# Handy short suffix for naming
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

output "service_labels" {
  description = "Computed names/labels you can reuse across modules/resources."
  value = {
    name         = format("%s-%s-%s", local.name_prefix, random_pet.service.id, random_string.suffix.result)
    short        = format("%s-%s", var.project_name, random_string.suffix.result)
    artifact_hex = random_id.artifact.hex
  }
}

output "password_example" {
  description = "Example generated password (sensitive)."
  value       = random_password.service.result
  sensitive   = true
}

output "common_tags" {
  description = "Merged tags map (user provided + computed)."
  value       = local.common_tags
}


