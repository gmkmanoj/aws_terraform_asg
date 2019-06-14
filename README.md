<h3>AWS EC2 ASG with Terraform - IaC </h3>

Here we are creating AWS ec2 instance and deploy node js code and setup nginx with high availability using terraform. 
End of the state of script execution you can access the web service with ELB public DNS name or you can use your own domain name with CNAME. The ec2 instance configured with Autoscaling group, The ELB will monitor ec2 instance healthcheck if any issue in reaching nginx the ASG will bring new instance. The node js (npm) service watched by superviord so if the node process stopped the superviord automatically start the instance.

<h4>Getting Started</h4>

These instructions will get you to setup ec2 instance which will have the node js backend and nginx front-end in efficient method.

<h4>Prerequisites:</h4>

You must have internet connection and administrator privileges to install the below softwares

OS : Any Linux (Here i used centos 7)
Git : Any version to get this repository from github
Terraform : v0.11.5
  Provisioner : Shell script 
AWS Access and Secret keys - it must EC2 fullAccess

<h4>Installation:</h4>

create one folder, here i created gogoui in /opt in my linux box

Download this repository

cd /opt/gogoui/

git clone https://github.com/gmkmanoj/aws_terraform_asg.git

cd aws_terraform_asg

Update AWS secret and access key in variable.tf file and also update other details based on your requirement
  Here i used t2.micro tier, as-south-1 and default VPC and subnets

Now time to bring up infra and service using terraform

terraform_asg]# terraform --version            # to Verify the terraform version

terraform_asg]# terraform init                 # Install provider pulgins

terraform_asg]# terraform plan                 # Verify the terraform execution plan and verify no errors


Yes the three instances are up now.

Now hit the haproxy URL http://10.11.11.100 now we will get response from one of the nginx server, do refresh and check the response from nginx server 2.

haproxylab]# curl http://10.11.11.100/ <br>
Hello World<br>
Response from : Nginx web1<br>

haproxylab]# curl http://10.11.11.100/ <br>
Hello World<br>
Response from : Nginx web2<br>

Now the Haproxy Load balancer setup completed and running in roundrobin method.

You can ssh the instance and stop one of the nginx web service to verify the haproxy getting response from other server.

SSH nginx web1

Note :
This setup only works on your local machine because the vm machine used private network settings. 
Reach me @ gmkmanoj@gmail.com for any questions.
