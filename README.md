
# [Bice] BeanStalk con IaC 



Se ha desarrollado un ejercicio para levantar el servicio BeanStalk utilizando Terraform, en donde se ha implementado el uso del servicio de forma modular


```terraform
resource "aws_iam_instance_profile" "ec2_eb_profile" {
  name = "ROLE_ec2-profile_BS"
  role = aws_iam_role.ec2_role.name

}

```
