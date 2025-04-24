#!/bin/bash
  # Log output for debugging
  exec > >(tee /var/log/user_data.log|logger -t user_data -s 2>/dev/console) 2>&1

  # In user_data.sh:
  # Ensure the variables are referenced like this:
  echo "Region: ${region}"
  echo "Cluster Name: ${cluster_name}"
  echo "EFS DNS Name: ${efs_dns_name}"
  echo "EFS DNS Name: ${ingress_hostname}"

   # Update package list and install prerequisites
  sudo apt update -y
  sudo apt install -y curl unzip docker.io docker-compose git nfs-common binutils rustc cargo stunnel4 pkg-config libssl-dev gettext

  # Install AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install

  aws eks  update-kubeconfig --name ${cluster_name} --region  ${region}


  # Start Docker and add permissions
  
  sudo usermod -aG docker ubuntu
  sudo systemctl stop docker
  sudo systemctl start docker
  sudo systemctl enable docker

  # # Verify Docker and awscli installation
  # docker --version
  # aws --version
  # ECR Login
    aws ecr get-login-password --region "${region}" | \
    docker login --username AWS --password-stdin ${ecr_repo_url} || {
    echo "ECR login failed"; exit 1;
}
  # Copy files from S3
  aws s3 cp s3://${bucket_name}/nginx /home/ubuntu/nginx --recursive
  aws s3 cp s3://${bucket_name}/certs /home/ubuntu/certs --recursive
  
  sudo chown ubuntu:ubuntu /home/ubuntu/nginx/nginx.conf
  sudo chmod 644 /home/ubuntu/nginx/nginx.conf
  
  sudo dpkg -i /home/ubuntu/nginx/amazon-efs-utils-2.1.0-1_all.deb
  sudo apt-get install -f -y

  # Mount EFS to /mnt/EdgeCortixRoot
  sudo mkdir -p /mnt/EdgeCortixRoot

  sudo mount -t efs -o tls ${efs_dns_name}:/ /mnt/EdgeCortixRoot
    
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)
  
  INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
  # Save Instance ID to file
  echo "Instance ID: $INSTANCE_ID" | tee /home/ubuntu/InstanceID.txt
  
  PRIVATE_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
  # Save Private IP to file
  echo "Private IP: $PRIVATE_IP" | tee /home/ubuntu/PrivateIP.txt
  
  cd /home/ubuntu

  echo "
  version: '3.8'
  services:
    nginx:
      image: nginx:latest
      container_name: nginx-proxy
      ports:
        - "80:80"
        - "443:443"  # Expose port 443 for HTTPS
      volumes:
        - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
        - ./certs/nginx-selfsigned.crt:/etc/ssl/certs/nginx-selfsigned.crt:ro
        - ./certs/nginx-selfsigned.key:/etc/ssl/private/nginx-selfsigned.key:ro
      depends_on:
        - app_auth
        - app_backend
        - app_frontend
      shm_size: '6gb'
      
    app_auth:
      image: ${auth_image}
      depends_on:
        - db
      environment:
        POSTGRES_USER: "postgres"
        POSTGRES_PASSWORD: "postgres"
        POSTGRES_DB: "postgres"
        POSTGRES_HOST: "db"
        POSTGRES_PORT: 5430
        DATABASE_URL: "postgres://postgres:postgres@db:5430/postgres"

    app_backend:
      image: ${backend_image}
      ports:
         - '6060:6060'
         - '6061:6061'
      depends_on:
        - app_auth
      environment:
        - NODE_ENV=production
        - AUTH_SERVICE_URL=http://app_auth:3000/api/auth/v1/validateJwt
        - ML_BACKEND_URL=http://${ingress_hostname}
        - WEBSOCKET_URL=ws://$${PRIVATE_IP}:6060
        - WEBSOCKET_COMPILATION_URL=ws://$${PRIVATE_IP}:6061
      volumes:
        - /mnt/EdgeCortixRoot:/mnt/EdgeCortixRoot
      shm_size: '6gb'
    
    app_frontend:
      image: ${frontend_image}
      environment:
        - NODE_ENV=production

    db:
      image: postgres:15.3-alpine3.18
      environment:
        POSTGRES_USER: "postgres"
        POSTGRES_PASSWORD: "postgres"
        POSTGRES_DB: "postgres"
      volumes:
        - pgdata:/var/lib/postgresql/data
  volumes:
    pgdata:
    shared_volumes:
  " > docker-compose.yml
  docker-compose up -d
  echo "Installation is completed" > /home/ubuntu/completion-log.txt
  
