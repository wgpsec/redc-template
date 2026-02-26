terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.21.0"
    }
  }
}

provider "google" {
  project = var.GCP_PROJECT_ID
  # region  = var.GCP_REGION
  # zone = var.zone
}