locals {
  default_tags = {
    project     = var.project_name
    environment = var.environment
    team        = "atlas-platform"
    cost-center = var.cost_center
    created-by  = var.created_by
    managed-by  = "terraform"
  }
}
