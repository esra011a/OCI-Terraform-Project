resource "oci_core_vcn" "vcn" {
  cidr_block     = var.cidr_block
  display_name   = var.vcn_display_name
  compartment_id = var.compartment_id

  //vcn_cidr=var.vcn_cider
  dns_label = var.vcn_dns_label

}
resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.nat_gateway_display_name

}
resource "oci_core_route_table" "route_table_nat_subnets" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "private-route-table"

  route_rules {
    #Required
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
  route_rules {
    destination       = "172.22.48.0/23" // null
    destination_type  = "CIDR_BLOCK"     // null
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
    route_type        = "STATIC" // null
  }
}
resource "oci_core_subnet" "Private_subnets" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  for_each       = var.subnets
  cidr_block     = each.value.cidr
  display_name   = each.value.sn_display_name
  dns_label      = each.value.dns_label
  // security-list-name = each.value.security-list-name 
  prohibit_public_ip_on_vnic = true //true
  route_table_id             = oci_core_route_table.route_table_nat_subnets.id
  //public_sn_display_name=var.public_sn_display_name
  //security_list_ids = [oci_core_security_list.sec_list[each.value.security_list_id].id]
  security_list_ids = [for key in keys(var.security_lists) : oci_core_security_list.sec_list[key].id]
  lifecycle {
    ignore_changes = [security_list_ids]
  }

}
resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = var.public_sn_cidr
  prohibit_public_ip_on_vnic = false //public
  display_name               = var.public_sn_display_name
  dns_label                  = "publicsubnet"
  route_table_id             = oci_core_route_table.ig.id
  security_list_ids          = [oci_core_security_list.public-sec-list.id]
  lifecycle {
    ignore_changes = all
  }
}
resource "oci_core_security_list" "public-sec-list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "public-security-list"
  egress_security_rules {
    stateless        = false
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    destination      = "0.0.0.0/0"
  }
  ingress_security_rules {
    stateless   = false
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 443
    }
  }


}
resource "oci_core_security_list" "sec_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  for_each       = var.security_lists
  //display_name = each.value.display_name
  display_name = each.value.display_name

  dynamic "ingress_security_rules" {
    for_each = each.value.ingress

    content {
      stateless   = ingress_security_rules.value.stateless
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      protocol    = ingress_security_rules.value.protocol

      tcp_options {
        min = ingress_security_rules.value.min
        max = ingress_security_rules.value.max
      }
    }
  }
  egress_security_rules {
    stateless        = false
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    destination      = "0.0.0.0/0"
  }


}
resource "oci_core_internet_gateway" "internet_gateway" {
  display_name   = var.internet_gateway_display_name
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true

}
resource "oci_core_route_table" "ig" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.route_table_name

  route_rules {
    #Required
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}



