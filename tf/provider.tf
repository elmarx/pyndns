terraform {
  required_providers {
    powerdns = {
      source  = "mmianl/powerdns"
      version = "2.5.0"
    }
  }
}

provider "powerdns" {
  api_key    = "secret-api-key"
  server_url = "http://localhost:8081"
}