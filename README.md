# PynDNS — Dynamic DNS Add-on for PowerDNS

A Dynamic DNS implementation for the [PowerDNS API](https://doc.powerdns.com/authoritative/http-api/index.html), designed for typical home networks with dynamic IP addresses and PowerDNS servers.

For example, it can be used with consumer routers such as the [FRITZ!Box](https://fritz.com/en/apps/knowledge-base/fritz-box-7590/30_Setting-up-dynamic-DNS-in-the-FRITZ-Box).

## Motivation

I self-host at home using IPv6 only, even behind DS-Lite. Having many public IP addresses is useful, but my ISP still changes the delegated prefix daily.

PynDNS updates all AAAA records in a given zone.

## Status

PynDNS has been running reliably for years, but is currently tailored to my specific use case.

## Usage

PynDNS expects the `ip6lanprefix` query parameter. All other parameters in the DynDNS request are ignored.

- Set `PDNS_SERVER_URL` to the PowerDNS API server URL.
- Set `API_KEY` to the value of the PowerDNS `api-key` configuration option.
- Set `BASIC_USERNAME` and `BASIC_SECRET` to credentials authorized to push DynDNS updates.
- Set `DYNAMIC_ZONE` to the name of the zone to update.

Run PynDNS