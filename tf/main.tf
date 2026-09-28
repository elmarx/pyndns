locals {
  records = {
    host1 = "2001:db8:1::1"
    host2 = "2001:db8:1::2"
    host3 = "2001:db8:1::3"
  }
}

resource "powerdns_zone" "this" {
  name        = "dyn.example.com."
  kind        = "Master"
}

resource "powerdns_record" "this" {
  for_each = local.records

  name    = "${each.key}.${powerdns_zone.this.name}"
  records = [each.value]
  ttl     = 300
  type    = "AAAA"
  zone    = powerdns_zone.this.name
}