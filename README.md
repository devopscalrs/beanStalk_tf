
<em> # [Bice] BeanStalk con IaC  </em>




Se ha desarrollado un ejercicio para levantar el servicio BeanStalk utilizando Terraform, en donde se ha implementado el uso del servicio a traves de una invocacion de modulo, el cual dicha invocación esta en el archivo main.tf

```terraform
#main.tf

module "beanstalk" {
  source = "./beanstalk"

  bice_vpc_id              = data.aws_vpc.default.id
  bice_name_application    = var.bice_name_application
  bice_environment         = var.bice_environment
  bice_solution_stack_name = var.bice_solution_stack_name

  instance_type      = var.instance_type
  vpc_public_subnets = toset(data.aws_subnets.vpc.ids)
  key_pair           = var.key_pair

}
```
Este modulo recibe varios parametros como variables, dichas variables son configuradas en el archivo terraform.tfvars, adicional se agregaron otras variables de configuracion


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

Se aprecia que tenemos 2 datos comentados que son **bice_vpc_id** y **public_subnets** esto es debido a que estamos haciendo uso de las VPC y sus subredes por defecto a traves del dataSource que nos proporciona terraform, pero si queremos hacer uso de una VPC y subred especifica lo podemos descomentar y declarar el parametro a necesitar, asi como tambien especificar en el archivo main.tf para que invoque a estas variables y no a los dataSource. Adicional estas otras variables agregadas como  **instance_type** y **key_pair** si no tenemos un dato especifico para estos, las podemos comentar al invocar el modulo y el proyecto por declaracion de las variables soportara la invocacion al modulo ya que estos datos tienen valores por defecto.

**Para ejecutar el proyecto satisfactoriamente en nuestro ambiente, solo debemos configurar las variables de entrada en el archivo terraform.tfvars**

# Modulo beanStalk

El modulo esta compuesto por 3 archivos

```
main.tf
output.tf
vars.tf

```

**beanstalk/vars.tf** Este archivo recibe las variables de entradas invocadas para la ejecucion del modulo, Adicional a eso se configuro el modulo para que reciba diferentes parametros de configuracion que nos permitira levantar el servicio beanstalk adaptado a la especificacion de algunos recursos, para eso solo debemos usar los parametros necesarios y parametizarlo al momento de invocar el modulo en el archivo main.tf del root principal, el modulo soportara estos parametro, de igual forma estos parametros tienen valores por defecto necesarios para levantar el servicio beanstalk de manera optima.

**Ejemplo de beanstalk/varstf** Variables con el min y max de Auto Scaling por defecto

```terraform
#=========  AUTOSCALING LAUNCH CONFIGURATION  =========== ###

variable "min_inst" {
  description = "min de instacia para el loadBalancer"
  type        = number
  default     = 1
}

variable "max_inst" {
  description = "max de instacia para el loadBalancer"
  type        = number
  default     = 2
}
```









