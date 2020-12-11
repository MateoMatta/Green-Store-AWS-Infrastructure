#Archivo de retorno de las variables de salida
#La salida seran las zonas de disponibilidad 
output "availability_zone" {
    value = [
        var.availability_zones
    ]
}

output "elb_public_dns" {
value = aws_elb.aik_elb.dns_name
}