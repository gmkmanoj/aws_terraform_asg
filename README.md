<h3>AWS EC2 ASG with Terraform - IaC </h3>

Here we are creating AWS ec2 instance and deploy the node js code and setting up nginx with high availability using terraform. 
After succcessful script execution you can access the web service with public DNS name by creating CNAME with ELB public DNS. The ec2 instance configured with Autoscaling group, The ELB will monitor ec2 instance healthcheck if any issue in reaching nginx the ASG(Auto Scaling Group) will bring up new instance. The node js (npm) service watched by superviord so if the node process stopped the superviord service itself automatically start the node js.

<h4>Getting Started</h4>

These instructions will get you to run terraform code to get the Web service which will have the node js backend and nginx front-end using AWS cloud services.

<h4>Prerequisites:</h4>

You must have internet connection and administrator privileges to install the below softwares

OS : Any Linux (Here i used centos 6.10)
Git : Any version to get this repository from github or you can download zip package
Terraform : v0.11.5
  Provisioner : Shell script - used to get node js code and setup supervisord. We can use ansible and other provisioner tools.              
AWS Access and Secret keys - it must have EC2 fullAccess

<h4>Execution:</h4>

create one folder, here i created gogoui in /opt in my linux box

Download this repository

cd /opt/gogoui/

git clone https://github.com/gmkmanoj/aws_terraform_asg.git

or 

download https://github.com/gmkmanoj/aws_terraform_asg/archive/master.zip and extract to the folder

cd aws_terraform_asg

Update AWS secret and access key in variable.tf file and also update other details based on your requirement
  Here i used t2.micro tier, as-south-1 and default security group, default VPC and subnets.
  Make sure your security group allowed All source traffic to access port 80.

Update server_name in nginx_conf.sh file with you domain url.
  The ELB public DNS url only return default index.html. The node js service configured in virutal host so the correct DNS url only return the response from node js.
  
Now time to bring up the infra and service using terraform

terraform_asg]# terraform --version            # to Verify the terraform version

terraform_asg]# terraform init                 # Install provider pulgins

terraform_asg]# terraform plan                 # Verify the terraform execution plan and verify no errors

terraform_asg]# terraform apply                # setup to environment and services

At the end of the above command execution we will get ELB public DNS url like 
http://ec2-13-233-46-87.ap-south-1.compute.amazonaws.com/ - the public IP 13.233.46.87

Create CNAME with above DNS url or add Host record in DNS 13.233.46.87 A dev.yourdomain.com and verify the "Hello world" page.

terraform_asg]# terraform show                

You can see now the terraform created AWS EC2, AMI, Launch Template, ASG, Target Group and Application Load balancer

if you want to remove the created AWS resources just run terraform destroy

terraform_asg]# terraform destroy

Reach me @ gmkmanoj@gmail.com for any questions.
