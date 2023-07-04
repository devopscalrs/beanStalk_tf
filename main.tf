provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}




################  MODULE BEANSTALK   ########################

module "beanstalk" {
  source = "./beanstalk"

  bice_vpc_id              = data.aws_vpc.default.id
  bice_name_application    = var.bice_name_application
  bice_environment         = var.bice_environment
  bice_solution_stack_name = var.bice_solution_stack_name

  instance_type      = var.instance_type
  vpc_public_subnets = toset(data.aws_subnets.vpc.ids)
  // key_pair           = var.key_pair

}


