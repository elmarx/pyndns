resource "powerdns_record" "ns_eathmer_de_a" {
  for_each = tomap({ "1" = local.nameservers[0], "2" = local.nameservers[1], "3" = local.nameservers[2] })
  name     = "ns${each.key}.${powerdns_zone.this["eathmer.de"].name}"
  records  = data.dns_a_record_set.inwx[each.value].addrs
  ttl      = 300
  type     = "A"
  zone     = powerdns_zone.this["eathmer.de"].name
}

resource "powerdns_record" "ns_eathmer_de_aaaa" {
  for_each = tomap({ "1" = local.nameservers[0], "2" = local.nameservers[1], "3" = local.nameservers[2] })
  name     = "ns${each.key}.${powerdns_zone.this["eathmer.de"].name}"
  records  = data.dns_aaaa_record_set.inwx[each.value].addrs
  ttl      = 300
  type     = "AAAA"
  zone     = powerdns_zone.this["eathmer.de"].name
}
