#Este archivo contiene las variables de entrada a la configuracón de main.tf de terraform
#Puertos de las aplicaciones
#Puerto FrontEnd
variable "port_aik_front"{
    default = 3030
    description = "Puerto de comunicacion con el Front de la aplicacion"
}
#Puerto BackEnd
variable "port_aik_back"{
    default = 3000
    description = "Puerto de comunicacion con el Back de la aplicacion"
}

#Variables usadas para la configuración de las instancias
#AMI
variable "aik_ami_id" {
    default = "ami-03657b56516ab7912"
    description = "ID de la imagen ami"
}
#Instance Type
variable "aik_instance_type"{
    default = "t2.micro"
    description = "Tipo de instancia"
}
#Maximo numero de instancias en autoscaling
variable "autoscaling_max"{
    default = "2"
    description = "Numero maximo de instancias en autoscaling"
}
#Minimo de numero de instancias en autoscaling
variable "autoscaling_min"{
    default = "2"
    description = "Numero minimo de instancias en autoscaling"
}

#Key name para la instancia ec2
variable "aik_key_name" {
  description = "Key pair name"
  default     = "estudianteAutomatizacion20202_3"
}

#Puerto para conexion remota
variable "port_ssh" {
    default = 22
    description = "Puerto para gestion remota"
}
#CDIR general para la VPC
variable "vpc_cidr" {
    default = "10.0.0.0/16"
    description = "CIDR de la VPC donde van a vivir las 2 zonas de disponibilidad c/u con una subnet"
}
#Zonas de disponibilidad
variable "availability_zones" {
  description = "zonas de disponibilidad a usar"
  default = "us-east-2a,us-east-2b"
}

#Variables para base de datos
variable "rds_db_username" {
  description = "Nombre de usuario para la database"
  default = "aikdbuser"
}

variable "rds_db_password" {
  description = "Password de la base de datos"
  default = "aikdbuser"
}

#Esto es una prueba
