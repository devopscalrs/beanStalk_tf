


Se Crear un rol para la instancia creada por beanStalk esto como un requisito indispensable para que la instancia pueda ejecutar ciertas acciones, por lo tanto se le otorga diferentes permisos



Genera todos los valores útiles a los que los módulos raíz podrían necesitar hacer referencia o que podrían necesitar compartir.


# Se ddddddddddd otra cosa

- Se  


```terraform
resource "aws_iam_instance_profile" "ec2_eb_profile" {
  name = "ROLE_ec2-profile_BS"
  role = aws_iam_role.ec2_role.name

}
```
