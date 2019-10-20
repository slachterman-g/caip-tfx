terraform {
  required_version = ">= 0.12"
}

module "dev_infrastructure" {
  source      = "github.com/jarokaz/terraform-gcp-kfp"
  project_id  = var.project_id
  region      = var.region
  zone        = var.zone
  name_prefix = var.name_prefix
}

# Add the root user with no password to Cloud SQL instance.
# This is the current limitation of Kubeflow Pipelines 
# For security reasons, the dev_infrastructure module creates an instance without any users
resource "google_sql_user" "root_user" {
  project  = var.project_id
  name     = "root"
  instance = module.dev_infrastructure.mysql_instance_name
}
