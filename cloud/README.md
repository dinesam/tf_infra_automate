

Contains terraform scripts and K8s manifests

## Prerequisites
Ensure that you have the following tools installed locally with necessary credentials:

- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)



## Getting started

Lets check the steps to setup the infra for the Kubernetes in AWS.

`Note: apt install commands given below are based on ubuntu environment, Please use appropriate commands according to your environment.`

# Setting Up AWS CLI

### Step 1: Install AWS CLI

If you haven't installed the AWS CLI, follow the steps in the AWS CLI installation guide for your operating system.

Refer the Prerequisites line No: 8

```
wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
## Step 2: Configure AWS CLI with aws configure
Run the aws configure command to set up the CLI for the first time:

```
aws configure
```
You will be prompted to provide the following information:

### AWS Access Key ID:
Enter your AWS Access Key ID. This is a unique identifier associated with your AWS account or IAM user.

### AWS Secret Access Key:
Enter the AWS Secret Access Key associated with the Access Key ID. Ensure it is kept secure as it grants access to your AWS resources.

### Default region name:
Enter the AWS region you want to work with (e.g., us-east-1, us-west-2, eu-west-1). The default region specifies where your AWS resources will be created.

### Default output format: (Optional)
Choose your preferred output format: json, text, or table. json is recommended for easy parsing.

# Setting up `kubectl` via Snap

### Step 1: Install Snap (if not already installed)

If Snap is not installed on your system, you can install it using the following commands:

- On **Ubuntu/Debian**:

```
sudo apt update
sudo apt install snapd

  ``` 

### Step 2: Install kubectl using Snap
Once Snap is installed, you can install kubectl with the following command:

```
sudo snap install kubectl --classic
```
This installs the latest stable version of kubectl on your system. The --classic flag is required because kubectl is a classic snap, meaning it requires full access to your system.

### Step 3: Verify the Installation
After the installation is complete, verify that kubectl is correctly installed by checking its version:

```
kubectl version --client
```

# Setting up Terraform on Ubuntu

### Step 1: Install Terraform using APT

1. **Update your package list** to ensure you have the latest versions of the software repositories:

```
sudo apt-get install -y software-properties-common

sudo add-apt-repository "deb [arch=amd64] https://apt.releases.hashicorp.com stable main"

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-get update
```
### Install Terraform:

```
sudo apt-get install terraform
```

## Step 2: Verify the Installation

After the installation is complete, verify that Terraform is correctly installed by checking its version:

```
terraform version
```
# Mandatory Dependencies 
1. Docker images are required in ECR.
2. Update the variables in the env folder infra.tfvars, deploy.tfvars and webapp.tfvars as per the requirements


# Run terraform scripts and apply K8s manifests
1.          cd infrastructure
2.          terraform init 
3.          terraform plan -var-file="../env/infra.tfvars"
4.          terraform apply -var-file="../env/infra.tfvars"
5.          cd ..
6.          aws eks  update-kubeconfig --name <your-cluster-name> --region  <your-region>
7.          cd deployment
8.          terraform init
9.          terraform plan -var-file="../env/deploy.tfvars"
10.         terraform apply -var-file="../env/deploy.tfvars"
11.         cd ..
12.         cd ec2webapp
13.         terraform init
14.         terraform plan -var-file="../env/webapp.tfvars"
15.         terraform apply -var-file="../env/webapp.tfvars"


## Destroy terraform scripts and k8s manifests
1.      cd ec2webapp
2.      terraform destroy -var-file="../env/webapp.tfvars"
3.      cd ..
4.      cd deployment
5.      terraform destroy -var-file="../env/deploy.tfvars"
6.      cd ..
7.      cd infrastructure
7.      terraform destroy  -var-file="../env/infra.tfvars"


## Diagram 

  project/
├── infrastructure/            # Infrastructure-specific configurations
│   ├── modules/               # Individual modules for infrastructure components
│   │   ├── eks/               # EKS-specific configurations
│   │   │   ├── main.tf        # Module definition for EKS
│   │   │   ├── variables.tf   # Variables specific to EKS
│   │   │   └── outputs.tf     # Outputs specific to EKS
│   │   ├── autoscaler/        # Autoscaler-specific configurations
│   │   │   ├── main.tf        # Module definition for Autoscaler
│   │   │   ├── variables.tf   # Variables specific to Autoscaler
│   │   │   └── outputs.tf     # Outputs specific to Autoscaler
│   │   ├── efs/               # EFS-specific configurations
│   │   │   ├── main.tf        # Module definition for EFS
│   │   │   ├── variables.tf   # Variables specific to EFS
│   │   │   └── outputs.tf     # Outputs specific to EFS
│   │   └── vpc/               # VPC-specific configurations
│   │       ├── main.tf        # Module definition for VPC
│   │       ├── variables.tf   # Variables specific to VPC
│   │       └── outputs.tf     # Outputs specific to VPC
│   ├── main.tf                # Main configuration for combining infrastructure modules
│   ├── variables.tf           # Shared variables for infrastructure
│   ├── outputs.tf             # Shared outputs for infrastructure
│   └── provider.tf            # Provider configurations specific to infrastructure
├── deployment/                # Kubernetes deployment configurations
│   ├── k8s_manifest/          # Kubernetes manifest files for custom resources
│   │   ├── alb.yaml           # Application Load Balancer configuration
│   │   ├── cluster_role.yaml  # ClusterRole configuration
│   │   ├── cluster_role_binding.yaml  # ClusterRoleBinding configuration
│   │   ├── deployment.yaml    # Deployment configuration
│   │   ├── hpa.yaml           # Horizontal Pod Autoscaler configuration
│   │   ├── pvc.yaml           # Persistent Volume Claim configuration
│   │   ├── role.yaml          # Role configuration
│   │   ├── role_binding.yaml  # RoleBinding configuration
│   │   ├── service-acc.yaml   # Service Account configuration
│   │   └── storageclass.yaml  # StorageClass configuration
│   │   ├── main.tf            # Kubernetes manifest module definition
│   │   ├── variables.tf       # Variables specific to Kubernetes manifests
│   │   └── outputs.tf         # Outputs specific to Kubernetes manifests
│   └── main.tf                # Deployment configurations
│   └── variables.tf           # Deployment-specific variables
│   └── outputs.tf             # Deployment-specific outputs
├── ec2webapp/                 # EC2 web application configurations
│   ├── main.tf                # EC2 resource definitions added
│   ├── variables.tf           # Variables specific to EC2 added
│   ├── outputs.tf             # Outputs specific to EC2 added
│   └── conf/                 # Configuration directory added
│       ├── certs/            # Certificates directory added
│       │   ├── certs.key     # Private key
│       │   └── certs.crt     # Certificate file
│       ├── efs-utils.deb     # EFS utility package
│       └── nginx/            # Nginx configuration directory added
│           └── nginx.conf    # Example nginx configuration (placeholder)
└── env/                       # Environment-specific variable values
    ├── infra.tfvars           # Infrastructure-specific variables
    ├── deploy.tfvars          # Deployment-specific variables
    └── webapp.tfvars          # Web application-specific variables


## Note:
 

1.   After the successful completion of the terraform apply in ec2webapp, you will get the public ip of the webapp. This ip can be used to access the application via browser. Please note that it takes about 10 minutes to finish the bootstrapping of the application


# References

1. [awscli] https://www.linkedin.com/pulse/guide-install-configure-aws-cli-ubuntu-satya-prakash-7ubze/
2. [kubectl] https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
3.  [terraform] https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli