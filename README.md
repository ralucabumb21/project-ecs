# Deploy and maintain a web server using Amazon Web Services

## Overview
![AWS-Project-Diagram](https://github.com/ralucabumb21/project-ecs/assets/50323787/bf414ef0-1b32-4264-9ab4-f916880df271)


The repository consists of a set of nested templates that deploy the following:
- A Virtual Private Cloud (VPC) with 2 public and private subnets
- An Elastic Container Service (ECS) Cluster deployed across two Availability Zones (AZs)
- An Application Load Balancer (ALB) to the public subnets to handle the inbound traffic for the ECS Service
- Centralized logging with Amazon Cloud Watch Logs


### Create Virtual Private cloud
The vpc-cft.template.json deploys the following network design:

| Item | CIDR Range | Usable IPs | Description |
| --- | --- | --- | --- |
| VPC | 10.192.0.0/16 | 65,536 | The whole range used for the VPC and all subnets |
| Public Subnet | 10.192.10.0/25 | 128 | The public subnet in the first Availability Zone |
| Public Subnet | 10.192.10.128/25 | 128 | The public subnet in the second Availability Zone |
| Private Subnet | 10.180.0.0/21 | 2,048 | The private subnet in the first Availability Zone |
| Private Subnet | 10.180.8.0/21 | 2,048 | The private subnet in the second Availability Zone |

The CIDR ranges are passed as parameters to the template.
You can adjust them with the desired ranges. If not, the above defaults will be used

### Build Docker image and upload to AWS Elastic Container Registry
Copy your Dockerfile to project/scripts or use the existing Dockerfile

Execute the `upload_to_ecr.sh <repository_name> <tag>` to build and upload the Docker image to AWS ECR.
 
For example:
```/project/scripts/upload_to_ecr.sh ralu/server latest```

***NOTE: Please make sure you have docker installed.***

### Create Application Load Balancer
The alb-cft.template.json deploys a `HTTP` Protocol and ip Type ALB.


***NOTE: If you use your custom Docker Image, make sure you change the Parameter AppContainerPort value.
The default is set to `80`.***


### Create Elastic Container Service
The ecs-cft.template.json deploys all necessary AWs Resources in order to create an ECS Service.

It creates the following resources:
- An ECS Cluster
- A Security Group (SG) that allows the ALB to access ECS
- A Identity and Access Management (IAM) Role, having 2 Amazon Managed Policies (`AmazonECS_FullAccess` and `AWSOpsWorksCloudWatchLogs`) attached.
- A Log Group to log events, having the retention days set to `7`. You can change the value as desired in the CFT.
- A Task definition, having the Cpu set to `256` and memory `512`. Based on what image + tag you specify in the ImageRepoTag CFT Parameter, that image will be run.
- An ECS Service, having the desired count set to `2`, launch type set to `fargate`.
