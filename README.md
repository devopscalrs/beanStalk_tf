
# [Bice] BeanStalk con IaC 



Se ha desarrollado un ejercicio para levantar el servicio BeanStalk utilizando Terraform, en donde se ha implementado el uso del servicio a traves de una invocacion de modulo, el cual dicha invocación esta en el archivo main.tf

```terraform
#main.tf

module "beanstalk" {
  source = "./beanstalk"

  bice_vpc_id              = data.aws_vpc.default.id
  bice_name_application    = var.bice_name_application
  bice_environment         = var.bice_environment
  bice_solution_stack_name = var.bice_solution_stack_name
}
```
Este modulo recibe varios parametros como variables, dichas variables son configuradas en el archivo terraform.tfvars, adicional a eso se agregaron otras variables de configuracion


```terraform
#terraform.tfvars

region                   = "us-east-1"
bice_name_application    = "bice_app_web"
bice_environment         = "prod-bice-app"
bice_solution_stack_name = "64bit Amazon Linux 2 v5.8.2 running Node.js 16"
//bice_vpc_id              = "VPC-ID"

instance_type = "t2.micro"
key_pair      = "terraform-keypair-new"
//public_subnets = ["subnet-0269ad79292f2b96f", "subnet-03688075bfdf14b1b"]
```

Se aprecia que tenemos 2 datos comentados que son **bice_vpc_id** y **public_subnets** esto es debido a que estamos haciendo uso de las VPC y sus subredes default a traves del dataSource que nos proporciona terraform, pero si queremos hacer uso de una VPC y subred especifica lo podemos descomentar y declarar el parametro a necesitar, asi como tambien especificar en el archivo main.tf para que invoque a estas variables y no a los dataSource 



