
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

  instance_type      = var.instance_type
  vpc_public_subnets = toset(data.aws_subnets.vpc.ids)
  key_pair           = var.key_pair

}
```
Este modulo recibe varios parametros como variables, dichas variables son configuradas en el archivo terraform.tfvars, adicional se agregaron otras variables de configuracion.


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


## Modulo beanStalk

El modulo esta compuesto por 3 archivos

```
main.tf
output.tf
vars.tf

```

**1-. beanstalk/vars.tf** Este archivo recibe las variables de entradas invocadas para la ejecucion del modulo, Adicional a eso se configuro el modulo para que reciba diferentes parametros de configuracion que nos permitira levantar el servicio beanstalk adaptado a la especificacion de algunos recursos, para eso solo debemos usar los parametros necesarios y parametizarlo al momento de invocar el modulo en el archivo main.tf del root principal, el modulo soportara estos parametro, de igual forma estos parametros tienen valores por defecto necesarios para levantar el servicio beanstalk de manera optima.


**Ejemplo** Variables con el min y max de Auto Scaling por defecto, que igual pueden recibir estas variables al invocar el modulo.


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


**2-. beanstalk/main.tf** Contiene la creacion del recurso Elastic Beanstalk con su aplicacion y su ambiente, estos reciben los parametros ya definidos al invocar el modulo, de lo contrario tendran valores por defecto como ya se menciono, dentro del ambiente del Elastic BeanStalk se ha parametizado todas las variables para soportar la entrada de diferentes valores de configuracion,  que nos permitan la creacion de distintas caracteristicas del servicio.

**Ejemplo**  La Plantilla de lanzamiento para el Auto Scaling Group y su medicion para el escalado, asi como tambien se incorporo que los registros del servicio se almacenen el cloudwatch. 

```terraform
 #=========  AUTOSCALING TRIGGER  =========== ###
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = var.rootVolumeType
  }


  #=========  CLOUDWATCH LOGS  =========== ###

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = var.cloudwatch_streamLogs


  #=========  AUTOSCALING TRIGGER  =========== ###

   setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = var.asg_trigger_measureName
  }

```


**Rol - Politicas - Permisos** Para que el servicio BeanStalk funcione es necesario la creacion de un rol de instancia que permitiria a la instancia creada del ambiente ejecutar acciones necesarias para su funcionamiento, por lo tanto se definio el recurso ***ec2_eb_profile** que tendra el rol y las politicas necesarias para esto, el rol de instancia creado tendra el nombre **role_ec2_profile_beanstalk**.

```terraform

resource "aws_iam_instance_profile" "ec2_eb_profile" {
  name = "ROLE_ec2-profile_BS"
  role = aws_iam_role.ec2_role.name

}

resource "aws_iam_role" "ec2_role" {
  name               = "ROLE_EC2_BEANSTALK"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  ]

  inline_policy {
    name   = "ROLE_EC2_BEANSTALK_INLINE"
    policy = data.aws_iam_policy_document.permissions.json
  }

}

```
**3-. beanstalk/output.tf** se agrega este archivo para proveer la salida de recursos fuera del modulo, como  por ejemplo en este caso he aplicado la salinda de DNS del ambiente levantado en beanstalk, esto con la funcionalidad de que dicho recurso u otros se puedan agregar naturalmente y sean utilizados por otros servicios que hagan uso del modulo, por lo tanto este recurso como ejemplo lo he expuesto al llamarlo en el archivo output.tf raiz, para que sea mostrada la funcionalidad del llamado del la variable que contiene el dns del ambiente una vez completado el tf apply.

## Conclusion 

Para desplegar exitosamente el proyecto, se debe configurar las variables dentro del archivo **terraform.tfvars** y en la raiz  de proyecyto ejecutar estos comandos

```
terraform init
terraform validate
terraform plan
terraform apply
```
