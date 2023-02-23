locals {
  nameservers = ["ns.inwx.de.", "ns2.inwx.de.", "ns3.inwx.eu."]

  zones_yaml = yamldecode(file("${path.module}/zones.yaml"))
  zones      = { for zone in local.zones_yaml : zone.name => { name = zone.name, nameservers = lookup(zone, "nameservers", local.nameservers) } }
  records = { for record in flatten([
    for zone in local.zones_yaml : [
      for subdomain in zone.records : ([
        for type, rr in subdomain : { zone : zone.name, name = subdomain.name, type = upper(type), rr = flatten([rr]) } # call flatten([ ]) to allow both arrays and strings
        if type != "name"
      ])
    ]
  ]) : record.name == "@" ? "${record.zone}_${lower(record.type)}" : "${record.name}_${record.zone}_${lower(record.type)}" => record }
}

resource "powerdns_zone" "this" {
  for_each    = local.zones
  name        = "${each.key}."
  kind        = "Master"
  nameservers = each.value.nameservers
}

resource "powerdns_record" "this" {
  for_each = local.records

  name    = each.value.name == "@" ? powerdns_zone.this[each.value.zone].name : "${each.value.name}.${powerdns_zone.this[each.value.zone].name}"
  records = each.value.type == "TXT" ? [for rr in each.value.rr : "\"${rr}\""] : each.value.rr
  ttl     = 300
  type    = each.value.type
  zone    = powerdns_zone.this[each.value.zone].name
}