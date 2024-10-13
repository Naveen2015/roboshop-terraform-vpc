module "vpc" {
  source = "git::https://github.com/Naveen2015/tf-module-vpc.git"
  env = var.env
  for_each = var.vpc

  cidr_block = each.value["cidr_block"]
  tags = local.tags
  subnets = each.value["subnets"]
}

output "kruthika" {
  value = module.vpc
}


module "app" {
  source = "git::https://github.com/Naveen2015/tf-module-app.git"
  for_each = var.app
  instance_type = each.value["instance_type"]
  bastion_cidr = var.bastion_cidr
  desired_capacity = each.value["desired_capacity"]
  max_size = each.value["max_size"]
  min_size = each.value["min_size"]
  tags = local.tags
  name= each.value["name"]


  subnet_ids = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null)
  name = each.value["name"]
  env = var.env
  vpc_id = lookup(lookup(module.vpc,"main",null),"vpc_id",null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["allow_app_cidr"],null),"subnet_cidrs",null)
}






#element(lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null),0)