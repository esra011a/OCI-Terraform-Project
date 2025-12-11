data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "vm_instances" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.instance_shape
  display_name        = var.instance_display_name
  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }
  // enable_encryption = var.enable_encryption
  source_details {
    source_type = var.source_type
    source_id   = var.source_id # or pass from locals.instances
  }
  create_vnic_details {
    assign_public_ip = var.assign_public_ip
    display_name     = var.vm_vinic_name
    subnet_id        = var.subnet_id
    private_ip       = var.private_ip

  }

  launch_options {
    is_pv_encryption_in_transit_enabled = true
  }


  freeform_tags = {
    APP_OWNER   = var.APP_OWNER
    Environment = var.Environment
  }
  metadata = {
    ssh_authorized_keys = var.ssh_key
  }
}
output "id" {
  value = oci_core_instance.vm_instances.id
}
