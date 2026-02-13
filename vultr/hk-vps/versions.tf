terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.22.1"
    }
  }
}

provider "vultr" {
  # API key is read from VULTR_API_KEY environment variable
  # Set via redc config.yaml or export VULTR_API_KEY="your_key"
}