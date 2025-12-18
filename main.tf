/**
 * # Fortigate Static Route configuration module
 *
 * This terraform module configures static routes on a firewall
 */
terraform {
  required_version = ">= 1.11.0"
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
      version = ">= 1.22.0"
    }
  }
}
locals {
  vdom_static_yaml = {
    for vdom in var.vdoms : vdom => yamldecode(file("${var.config_path}/${vdom}/static.yaml")) if fileexists("${var.config_path}/${vdom}/static.yaml")
  }

  routes = flatten([
    for vdom in var.vdoms : [
      for route in try(local.vdom_static_yaml[vdom], []) : [merge(route, { vdom = vdom })]
    ]
  ])
}

resource "fortios_router_static" "static_route" {
  for_each            = { for route in try(local.routes, []) : "${route.dst}_${try(route.gateway, try(route.blackhole, "disable") == "enable" ? "blackhole" : try(route.device, ""))}" => route }
  device              = try(each.value.device, null)
  dst                 = each.value.dst
  gateway             = try(each.value.gateway, null)
  vdomparam           = each.value.vdom
  bfd                 = try(each.value.bfd, null)
  blackhole           = try(each.value.blackhole, null)
  distance            = try(each.value.distance, null)
  dynamic_gateway     = try(each.value.dynamic_gateway, null)
  internet_service    = try(each.value.internet_service, null)
  link_monitor_exempt = try(each.value.link_monitor_exempt, null)
  priority            = try(each.value.priority, null)
  src                 = try(each.value.src, null)
  status              = try(each.value.status, null)
  virtual_wan_link    = try(each.value.virtual_wan_link, null)
  vrf                 = try(each.value.vrf, null)
  weight              = try(each.value.weight, null)
}
