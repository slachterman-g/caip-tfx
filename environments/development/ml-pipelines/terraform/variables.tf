variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "location" {
    description = "The location for the environment's components"
    type        = string
}

variable "notebook_instance_name" {
    description = "The name of the notebook instance to"
    type        = string
}

variable "datasets_bucket_name" {
    description = "The name of the GCS bucket for demo datasets"
    type        = string
}

variable "notebook_image" {
    description = "The image to use for the AI Platform notebook"
    type        = string
}