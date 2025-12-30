output "load_balancer_id" {
  value = oci_load_balancer_load_balancer.public_lb
}
/*output "load_balancer_ip" {
  value = oci_load_balancer_load_balancer.public_lb.ip_addresses
}*/

output "load_balancer_backendset" {
  value = oci_load_balancer_backend_set.backend_set
}
output "load_balancer_listener" {
  value = oci_load_balancer_listener.https_listener
}
output "load_balancer_rule_set" {
  value = oci_load_balancer_rule_set.geo_restriction
}

output "backend_set_name" {
  value       = oci_load_balancer_backend_set.backend_set.name
  description = "Backend set name"
}
output "listener_name" {
  value       = oci_load_balancer_listener.https_listener.name
  description = "Listener name"
}
