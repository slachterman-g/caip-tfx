terraform {
  required_version = ">= 0.12"
}

module "dev_infrastructure" {
  source      = "github.com/jarokaz/terraform-gcp-kfp"
  project_id  = var.project_id
  region      = var.region
  name_prefix = var.name_prefix
}