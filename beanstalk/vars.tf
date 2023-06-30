variable "bice_vpc_id" {
  description = "ID de la VPC"
  type        = string

}

variable "bice_name_application" {
  description = "Nombre del beanstalk application"
  type        = string

}

variable "bice_environment" {
  description = "Nombre del environment de beanstalk"
  type        = string

}
variable "bice_solution_stack_name" {
  description = "Stack para el envirioment"
  type        = string

}


#====================  ELASTIC BEANSTALK ENVIRONMENT  ======================== ###


variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
}



variable "tier" {
  description = "Tipo de capa a usar"
  type        = string
  default     = "WebServer"
}


variable "key_pair" {
  description = "keypair para las instancias creadas"
  type        = string
  default     = ""
}

variable "vpc_publicIp" {
  description = "AssociatePublicIpAddress"
  type        = bool
  default     = true
}

variable "vpc_public_subnets" {
  description = "Todos los id de los subnets donde se aprovisionara el LB"
  type        = list(string)
}

variable "eb_env_httpCode" {
  description = "MatcherHTTPCode"
  type        = number
  default     = 200
}

variable "eb_env_loadBalancer" {
  description = "LoadBalancerType"
  type        = string
  default     = "application"
}

variable "vpc_elbScheme" {
  description = "Especifique internalsi desea crear un balanceador de carga interno en su VPC de Amazon para que no se pueda acceder a su aplicación de Elastic Beanstalk desde fuera de su VPC de Amazon"
  type        = string
  default     = "internet facing"
}

variable "eb_healReporting" {
  description = "SystemType"
  type        = string
  default     = "enhanced"
}


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

variable "rootVolumeType" {
  description = "RootVolumeType"
  type        = string
  default     = "gp3"
}


variable "rootVolumeSize" {
  description = "RootVolumeSize"
  type        = number
  default     = 20
}

variable "rootVolumeIOPS" {
  description = "RootVolumeIOPS"
  type        = number
  default     = 3000
}

variable "rootVolumeThroughput" {
  description = "RootVolumeThroughput"
  type        = number
  default     = 125
}


#=========  CLOUDWATCH LOGS  =========== ###

variable "cloudwatch_streamLogs" {
  description = "StreamLogs"
  type        = bool
  default     = true
}


variable "cloudwatch_deleteLogs" {
  description = "DeleteOnTerminate"
  type        = bool
  default     = true
}

variable "cloudwatch_retention" {
  description = "RetentionInDays"
  type        = number
  default     = 7
}

#=========  AUTOSCALING TRIGGER  =========== ###

variable "asg_trigger_measureName" {
  description = "MeasureName"
  type        = string
  default     = "NetworkOut"
}

variable "asg_trigger_statistic" {
  description = "Statistic"
  type        = string
  default     = "Average"
}

variable "asg_trigger_unit" {
  description = "Unit"
  type        = string
  default     = "Percent"
}


variable "asg_trigger_LowerThreshold" {
  description = "LowerThreshold"
  type        = number
  default     = 2000000
}

variable "asg_trigger_upperThreshold" {
  description = "UpperThreshold"
  type        = number
  default     = 6000000
}

variable "asg_trigger_upperBreachScaleIncrement" {
  description = "UpperBreachScaleIncrement"
  type        = number
  default     = 1
}

variable "asg_trigger_lowerBreachScaleIncrement" {
  description = "LowerBreachScaleIncrement"
  type        = number
  default     = -1
}
