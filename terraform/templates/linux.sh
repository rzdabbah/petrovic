#! /bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

repo_url = ${ECR_REPO_URL}
repo_url = ${ECR_IMAGE_NAME}
sudo aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${repo_url}/${image_name}
sudo docker docker pull ${repo_url}/${image_name}:latest
sudo docker run --env-file ../env_file.env ${image_name}