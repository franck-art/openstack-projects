data "openstack_networking_network_v2" "ext_network" {
  name = "public1"
}

resource "openstack_networking_router_v2" "devops_router" {
  name                = "devops-router-tf"
  admin_state_up      = true
  external_network_id = "9cd4fa81-8616-4a2d-af0f-a910890b7e52"
}

resource "openstack_networking_network_v2" "devops_network" {
  name           = "devops-network-tf"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "devops_subnet" {
  name       = "devops-subnet-tf"
  network_id = openstack_networking_network_v2.devops_network.id
  cidr       = "192.168.1.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "devops_router_interface_1" {
  router_id = openstack_networking_router_v2.devops_router.id
  subnet_id = openstack_networking_subnet_v2.devops_subnet.id
}

resource "openstack_networking_secgroup_v2" "devops_sg" {
  name        = "devops-sg-tf"
  description = "a security group"

}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  for_each          = var.security_groups
  direction         = each.value.direction
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.prefix
  security_group_id = openstack_networking_secgroup_v2.devops_sg.id
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}

resource "openstack_compute_instance_v2" "devops_instance" {
  name            = "devops-compute-tf"
  image_id        = "7807500c-92bd-4969-ae05-d767b6efd57a"
  flavor_id       = "01b2470b-953a-4d10-88d5-7ed0619e7af1"
  key_pair        = "devops"
  security_groups = ["default", openstack_networking_secgroup_v2.devops_sg.name]
  user_data       = data.template_file.user_data.rendered
  network {
    name = openstack_networking_network_v2.devops_network.name
    port = openstack_networking_port_v2.port_1.id
  }
}

resource "openstack_networking_floatingip_v2" "devops_floatip" {
  pool = data.openstack_networking_network_v2.ext_network.name
}

resource "openstack_networking_port_v2" "port_1" {
  name           = "devops-network-port"
  network_id     = openstack_networking_network_v2.devops_network.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.devops_subnet.id
  }
}

resource "openstack_networking_floatingip_associate_v2" "devops_floatip_ass" {
  floating_ip = openstack_networking_floatingip_v2.devops_floatip.address
  port_id     = openstack_networking_port_v2.port_1.id
}
