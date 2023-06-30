#====================  CREATE INSTANCE PROFILE  ======================== ###

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

## Se crea politica inline para que sea parte inherente de la politica que estamos creando 1 a 1 del rol,


data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "permissions" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeInstanceStatus",
      "ssm:*",
      "ec2messages:*",
      "s3:*",
      "sqs:*"
    ]
    resources = ["*"]
  }
}









#====================  ELASTIC BEANSTALK APPLICATION  ======================== ###


resource "aws_elastic_beanstalk_application" "bice_app" {
  name = var.bice_name_application
}

#====================  ELASTIC BEANSTALK ENVIRONMENT  ======================== ###

resource "aws_elastic_beanstalk_environment" "beanstalk_app_bice_env" {
  name                = var.bice_environment
  application         = aws_elastic_beanstalk_application.bice_app.name
  solution_stack_name = var.bice_solution_stack_name
  tier                = var.tier

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.bice_vpc_id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2_eb_profile.name
  }

  /*setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.ec2_role.name
  }*/

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = var.vpc_publicIp
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.vpc_public_subnets)
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = var.eb_env_httpCode
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = var.eb_env_loadBalancer
    # Se define el tipo de loadbalancer
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = var.vpc_elbScheme
    #Especifique internalsi desea crear un balanceador de carga interno en su VPC de Amazon para que no se pueda acceder a su aplicación de Elastic Beanstalk desde fuera de su VPC de Amazon.
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.vpc_public_subnets)
    #Los ID de la subred o subredes para el balanceador de carga elástico
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = var.eb_healReporting
  }

  #=========  AUTOSCALING LAUNCH CONFIGURATION  =========== ###

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.min_inst
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_inst
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.key_pair

  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = var.rootVolumeType
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = var.rootVolumeSize
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeIOPS"
    value     = var.rootVolumeIOPS
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeThroughput"
    value     = var.rootVolumeThroughput
  }

  #=========  CLOUDWATCH LOGS  =========== ###

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = var.cloudwatch_streamLogs

  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = var.cloudwatch_deleteLogs

  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = var.cloudwatch_retention

  }


  #=========  AUTOSCALING TRIGGER  =========== ###


  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = var.asg_trigger_measureName
    # Nombre de la media para esacalar
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = var.asg_trigger_statistic
    # Estadistica de uso por el trigger
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = var.asg_trigger_unit
    # Mediciion
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = var.asg_trigger_LowerThreshold
    ### Si la medición cae por debajo de este número durante la duración de la infracción, se invoca un disparador.
  }


  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = var.asg_trigger_upperThreshold
    #Si la medida es superior a este número durante la duración de la infracción, se invoca un activador. 
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = var.asg_trigger_upperBreachScaleIncrement
    #Especifica cuántas instancias de Amazon EC2 agregar al realizar una actividad de escalado.
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = var.asg_trigger_lowerBreachScaleIncrement
    ##Cuántas instancias de Amazon EC2 eliminar al realizar una actividad de escalado.
  }


}

