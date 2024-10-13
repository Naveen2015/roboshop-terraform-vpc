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