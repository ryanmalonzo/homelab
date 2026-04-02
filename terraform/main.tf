locals {
  root_domain = "chaldea.dev"
  cname_subdomains = [
    "pangolin",
    "pdf",
    "music",
    "push",
    "photos"
  ]

  internal_dns_records = [
    {
      name    = "*.internal.${local.root_domain}"
      type    = "A"
      content = var.tailscale_ip
    }
  ]

  dns_records = concat(
    [
      {
        name    = local.root_domain
        type    = "A"
        content = var.pangolin_ip
      }
    ],
    [
      for sub in local.cname_subdomains : {
        name    = "${sub}.${local.root_domain}"
        type    = "CNAME"
        content = local.root_domain
      }
    ],
    local.internal_dns_records
  )
}

resource "cloudflare_dns_record" "dns_records" {
  for_each = { for rec in local.dns_records : rec.name => rec }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = 1
  proxied = false
}

