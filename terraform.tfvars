address_space = "10.0.0.0/22"
subnets = {
  private_endpoints = {
    size = 28
    # has_nat_gateway            = false
    # has_network_security_group = true
  }
}
tags = {
  env   = "AVM Lab"
  dept  = "Skillable"
  owner = "Jude Chen"
}
