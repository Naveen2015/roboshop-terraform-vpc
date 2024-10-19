module "vpc" {
  source = "git::https://github.com/Naveen2015/tf-module-vpc.git"
  env = var.env
  for_each = var.vpc

  cidr_block = each.value["cidr_block"]
  tags = local.tags
  subnets = each.value["subnets"]
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_vpc_rtid = var.default_vpc_rtid
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
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null)
  name = each.value["name"]
  env = var.env
  vpc_id = lookup(lookup(module.vpc,"main",null),"vpc_id",null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["allow_app_cidr"],null),"subnet_cidrs",null)
}

module "docdb" {
  source         = "git::https://github.com/Naveen2015/tf-module-docdb.git"
  for_each       = var.docdb
  env            = var.env
  subnets = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  tags           = local.tags
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
  engine_version = each.value["engine_version"]
  kms_arn        = var.kms_arn
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

}