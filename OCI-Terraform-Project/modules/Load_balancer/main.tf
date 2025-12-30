resource "oci_load_balancer_load_balancer" "public_lb" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  shape          = var.shape
  subnet_ids     = var.subnet_ids
   is_private = var.is_private
}
/*

resource "oci_load_balancer_certificate" "cert" {
  load_balancer_id = module.load_balancer.load_balancer_id
  certificate_name = "my-cert"
  public_certificate = file("./certs/fullchain.pem")
  private_key        = file("./certs/privkey.pem")
}

*/
resource "oci_load_balancer_backend_set" "backend_set" {
  name             = var.backend_set_name
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  policy           = var.lb_policy

  health_checker {
  
  protocol = var.health_protocol               # "HTTP" or "TCP"
    url_path = var.health_url_path               # "/" when protocol=HTTP
    port     = var.health_port                   # 80

  }
}

resource "oci_load_balancer_backend" "nginx_backend_vm" {
  
  
 backendset_name  = oci_load_balancer_backend_set.backend_set.name
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  ip_address       = var.linux_backend_ip
  port             = var.backend_port

}
resource "oci_load_balancer_backend" "IIS_backend_vm" {
 

backendset_name  = oci_load_balancer_backend_set.backend_set.name
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  ip_address       = var.windows_backend_ip
  port             = var.backend_port

}

resource "oci_load_balancer_listener" "https_listener" {
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  name             = var.listener_name
  protocol         = var.listener_protocol//HTTPS
  port             = var.listener_port

  default_backend_set_name = oci_load_balancer_backend_set.backend_set.name

 dynamic "ssl_configuration" {
    for_each = var.listener_protocol == "HTTPS" ? [1] : []
    content {
      certificate_name        = var.certificate_name
      verify_peer_certificate = false
      # Note: certificate must be uploaded to LB (via API/Console) with this certificate_name
    }
  }

  
}



resource "oci_load_balancer_rule_set" "geo_restriction" {
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  name             = var.geo_rule_set_name

  items {// (Required) (Updatable) An array of rules that compose the rule set
    action = "ALLOW"
    conditions {
      attribute_name  = "SOURCE_IP_ADDRESS"
      attribute_value = "COUNTRY_CODE:${var.geo_country_code}" # e.g., Saudi Arabia: SA
    }
  }
}