data "dns_a_record_set" "inwx" {
  for_each = toset(local.nameservers)
  host     = each.key
}

data "dns_aaaa_record_set" "inwx" {
  for_each = toset(local.nameservers)
  host     = each.key
}