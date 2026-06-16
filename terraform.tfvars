vnet_name     = "vnet-demo-dev-swedencentral-001"
address_space = "10.0.0.0/22"

subnets = {
  subnet1 = {
    name             = "private_endpoints_subnet"
    address_prefixes = ["10.0.0.0/28"]
  }
}

storage_account_name = "stodemodevswedenc93847"

tags = {
  env   = "AVM Lab"
  dept  = "Skillable"
  owner = "Jude Chen"
}
