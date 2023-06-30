
variable "region" {}

variable "bice_name_application" {}

variable "bice_environment" {}

variable "bice_solution_stack_name" {}

//variable "bice_vpc_id" {}

//variable "public_subnets" {}



variable "key_pair" {
  description = "nombre de key pair asociado a la instancia"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
  default     = "t2.micro"
}




