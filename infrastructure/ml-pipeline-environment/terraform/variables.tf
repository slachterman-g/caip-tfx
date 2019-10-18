variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "region" {
    description = "The region for the environment's components"
    type        = string
}

variable "zone" {
    description = "The zone for the GKE cluster"
}

variable "name_prefix" {
    description = "The name prefix to add to the resource names"
    type        = string
}

