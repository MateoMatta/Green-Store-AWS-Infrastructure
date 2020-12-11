# diagram.py
from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.management import AutoScaling
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("AIK Portal diagram", show=False):
   
   
    with Cluster("Availability Zone A"):
        instance1 = EC2("EC2")
        db1 = RDS("RDS (Master)")
        instance1 - db1


    with Cluster("Availability Zone B"):
        instance2 = EC2("EC2")
        db2 = RDS("RDS (Standy)")
        
        instance2 - db2


    autosc = AutoScaling("autoscaler")
    autosc - instance1
    loadbalancer = ELB("loadbalancer")
    instance1 - instance2
    db1 - db2
    
    loadbalancer - instance1
    loadbalancer - instance2
    