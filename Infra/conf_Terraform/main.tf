#Configuración para el proveedor donde se desplegará la infraestructura
#Nomenclatura --> resource <PROVIDER> <TYPE> <NAME>
provider "aws"{
    region = "us-east-2"
}

#VPC

data "aws_vpc" "aik_vpc" {
  id = "vpc-025ce59ecf7aed804"
}

#Basados en el diagrama de la solución los recursos a crear son: 2 intancias EC2, 2 zonas de disponibilidad, 1 balanceador de carga, 1 auto-scaling-group y 2 RDS.
#Creacion de la VPC para el portal de aik
# resource "aws_vpc" "aik_vpc" {
#     # Name = "aik-student3-vpc"
#     cidr_block = var.vpc_cidr
#     instance_tenancy = "default"

#     tags = {
#         name = "aik-student3-vpc"
#   } 
# }

#Internet Gateway como puerta de enlace a los recursos en la nube 
data "aws_internet_gateway" "aik_igw" {
    #name = "aik-igw"
   internet_gateway_id = "igw-097d3d1e5513c7338"
}




#Creacion de las subnets
#Cantidad de subnets 2
resource "aws_subnet" "aik_subnet_1" {
    #name = "aik-subnet-1"
    vpc_id                  = data.aws_vpc.aik_vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
    availability_zone       = element(split(",", var.availability_zones), 0)
    map_public_ip_on_launch = true

    tags = {
        Name = "auto-subnet-public"
    }
}

#Subnet 2
resource "aws_subnet" "aik_subnet_2" {
    #name = "aik-subnet-2"
    vpc_id                  = data.aws_vpc.aik_vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, 7)
    availability_zone       = element(split(",", var.availability_zones), 1)
    map_public_ip_on_launch = true

    tags = {
        Name = "auto-subnet-public"
    }
}

resource "aws_route_table" "aik_route_table" {
  vpc_id = data.aws_vpc.aik_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.aik_igw.id
  }

  tags = {
    Name = "automatizacion-est3_public_rtb"
  }
}



resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.aik_subnet_1.id
  route_table_id = aws_route_table.aik_route_table.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.aik_subnet_2.id
  route_table_id = aws_route_table.aik_route_table.id
}

#Se crea un security group para permitir el acceso al pueto de la aplicacion
resource "aws_security_group" "aik_security_group" {
    #name = "aik-security-group"
    vpc_id      = data.aws_vpc.aik_vpc.id
    #vpc_id      = [aws_vpc.aik_vpc.id]
    description = "Grupo de seguridad para el aplicativo aik"

    #Acceso http desde cualquier direccion
    ingress {
        from_port = var.port_aik_front
        to_port = var.port_aik_front
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    ingress {
        from_port   = var.port_ssh
        to_port     = var.port_ssh
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Salida de internet
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

}

#Creacion de un balanceador de carga
resource "aws_elb" "aik_elb" {
    name = "aik-elb"
    subnets = [aws_subnet.aik_subnet_1.id, aws_subnet.aik_subnet_2.id]
    security_groups = [aws_security_group.aik_security_group.id]
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/"
        interval = 30
    }
}

#El configuration Launcher es el template que se usa para lanzar instancias de EC2

#Las variables se encuentran en el archivo variables.tf
resource "aws_launch_configuration" "aik_configuration"{
    name = "placeholder-aik-lc"
    image_id = var.aik_ami_id
    instance_type = var.aik_instance_type
    security_groups = [aws_security_group.aik_security_group.id]
    key_name = var.aik_key_name
    #Gestion de la configuracion con saltstack ....
    user_data = file("../scripts/awsLaunchConfiguration.sh")
    #.......
}
#Creacion del autoscaling group
resource "aws_autoscaling_group" "aik_autoscaling"{
    name = "aik-autoscaling-3"
    force_delete = true
    min_size = var.autoscaling_max
    max_size = var.autoscaling_min
    vpc_zone_identifier = [aws_subnet.aik_subnet_1.id, aws_subnet.aik_subnet_2.id]
    #Lo que debe realizar cada vez que escale
    launch_configuration = aws_launch_configuration.aik_configuration.name
    #Se ubica la nueva instancia dentro del balanceador de carga
    load_balancers = [aws_elb.aik_elb.name]
    tag {
        key = "Name"
        value = "aik-autoscaling-3"
        propagate_at_launch = true
    }
}


resource "aws_db_subnet_group" "aik-db-subn-group" {
  name       = "group"
  subnet_ids = [aws_subnet.aik_subnet_1.id, aws_subnet.aik_subnet_2.id]
  tags = {
    Name = "Subnet group for DB"
  }
}


#RDS base de datos
# resource "aws_db_instance" "aik_db_rds" {
#     allocated_storage    = 20
#     storage_type         = "gp2"
#     engine               = "mysql"
#     engine_version       = "5.7"
#     instance_class       = "db.t2.micro"
#     name               = "aik_db_rds"
#     username             = var.rds_db_username
#     password             = var.rds_db_password
#     parameter_group_name = "default.mysql5.7"
#     port = 3306
#     publicly_accessible = false
#     multi_az = false
#     vpc_security_group_ids = [aws_security_group.aik_security_group.id]
#     db_subnet_group_name = aws_db_subnet_group.aik-db-subn-group.name
#     final_snapshot_identifier = "rdsDatabase"
# }

#Bucket S3
# resource "aws_s3_bucket" "aik_s3_configuration" {
#     bucket = "ais-bucket-config"
#     acl    = "private"
#     tags = {
#         Name        = "aik_s3_configuration"
#         #Environment = "Dev"
#     }
# }

#Crear una instancia EC2 para el back
#resource "aws_instance" "aik_back" {
#	ami = var.aik_ami_id
#	instance_type = "t2.micro"
#	
#	tags = {
#		Name = "EC2 BackEnd AIK"
#	}
#}

#Crear una instancia EC2 para el front
#resource "aws_instance" "aik_front" {
#	ami = var.aik_ami_id
#	instance_type = var.aik_instance_type
#   
#	tags = {
#		Name = "EC2 FrontEnd AIK"
#	}
#}