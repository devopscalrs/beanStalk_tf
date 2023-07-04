output "dns_env_modulo" {
  value       = aws_elastic_beanstalk_environment.beanstalk_app_bice_env.cname
  description = "Se agrega endpoint del ambiente como salida"
}
