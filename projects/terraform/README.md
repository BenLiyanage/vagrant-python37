This project is a sample terraform project that deploys a very simple n-tier architecture using docker.  

# Features

* N-Tier web server architecture, using 2 servers behind a load balancer.
* Uses Docker containers for easy deployment.
* Terraform.  Because planning is amazing.
* Really basic bash script example (`./app/deploy.sh`) 

# Limitations

 Note that this configuration is not a battle hardened 
production configuration, but a showcase of my docker and terraform ability.  Feel free to ask me about
mitigating any of these issues.

* The VPC configuration is incomplete.  This VPC configuration is meant to be imported from your default VPC.  
This demonstrates applying terraform to a legacy environment.
* Network security is pretty lose.  Our ECS containers are just out on the internet, as opposed to on a private subnet.
* The docker container is not particularly productionized, and using the stock development web server.
* The load balancer configuration is pretty minimal, using only two zones, and no robust healthcheck.
* Deployments have downtime.  Plenty of features to mitigate this, but they add complexity.
* No autoscaling configured for simplicity.
* No vanity url.
* No SSL

# Installation

* Install terraform (ex. `brew install terraform`)
* Install the AWS command line.
  * `pip3 install awscli`
  * `aws confdigure` -- provide your info here.
* Run `terraform init`
* Map the VPC, and subnets a & b to the appropriate resources:
  * `terraform import aws_vpc.main vpc-XXXXXXXX`
  * `terraform import aws_subnet.main_subnet_a subnet-XXXXXXXX`
  * `terraform import aws_subnet.main_subnet_b subnet-XXXXXXXX`
* Run `terraform plan` to see the changes terraform will make to your infrastructure.
* Run `terraform apply` to apply the changes.
* Deploy the docker container:
  * `cd app`
  * `./deploy.sh`
* Check out your web server.  See the load balancer for the stock A-name created.