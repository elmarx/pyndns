terraform {
  required_providers {
    powerdns = {
      source  = "pan-net/powerdns"
      version = "1.5.0"
    }

    dns = {
      source  = "hashicorp/dns"
      version = "3.2.3"
    }
  }
}
