module "vpc" {
  source   = "git::https://github.com/Naveen2015/tf-module-vpc.git"
  env      = var.env
  for_each = var.vpc

  cidr_block       = each.value["cidr_block"]
  tags             = local.tags
  subnets          = each.value["subnets"]
  default_vpc_id   = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_vpc_rtid = var.default_vpc_rtid
}

output "kruthika" {
  value = module.vpc
}


module "app" {
  depends_on = [module.vpc,module.docdb,module.alb,module.elasticache,module.rabbitmq,module.rds]
  source           = "git::https://github.com/Naveen2015/tf-module-app.git"
  for_each         = var.app
  instance_type    = each.value["instance_type"]
  bastion_cidr     = var.bastion_cidr
  desired_capacity = each.value["desired_capacity"]
  max_size         = each.value["max_size"]
  min_size         = each.value["min_size"]
  tags             = local.tags
  kms_arn        = var.kms_arn
  parameters = each.value["parameters"]
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  name             = each.value["name"]
  env              = var.env
  app_port = each.value["app_port"]
  domain_name = var.domain_name
  domain_id = var.domain_id
  listener_arn= lookup(lookup(module.alb, each.value["lb_type"], null), "listener_arn", null)
  lb_dns_name= lookup(lookup(module.alb, each.value["lb_type"], null), "dns_name", null)
  dns_name = each.value["name"] == "frontend" ? each.value["dns_name"] : "${each.value["name"]}-${var.env}"

  listener_priority = each.value["listener_priority"]
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_app_cidr"], null), "subnet_cidrs", null)
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

module "rds" {
  source         = "git::https://github.com/Naveen2015/tf-module-rds.git"
  for_each       = var.rds
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

module "elasticache" {
  source         = "git::https://github.com/Naveen2015/tf-module-elasticache.git"
  for_each       = var.elasticache
  env            = var.env
  subnets = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  tags           = local.tags
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
  engine_version = each.value["engine_version"]
  kms_arn        = var.kms_arn
  num_node_groups = each.value["num_node_groups"]
  replicas_per_node_group=each.value["replicas_per_node_group"]
  node_type = each.value["node_type"]

}

module "rabbitmq" {
  source         = "git::https://github.com/Naveen2015/tf-module-amazon-mq.git"
  for_each       = var.rabbitmq
  subnets = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  tags           = local.tags
  env            = var.env
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)

  kms_arn        = var.kms_arn

  instance_type = each.value["instance_type"]
  bastion_cidr= var.bastion_cidr

}

module "alb" {
  source = "git::https://github.com/Naveen2015/tf-module-alb.git"
  for_each = var.alb
  env = var.env
  vpc_id = local.vpc_id
  tags = local.tags
  name = each.value["name"]
  internal  = each.value["internal"]
  subnets = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_alb_cidr = each.value["name"]=="public"? [ "0.0.0.0/0" ]: lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_alb_cidr"], null), "subnet_cidrs", null)


}
