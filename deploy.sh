#!/bin/bash

# Set AWS credentials and region
export AWS_ACCESS_KEY_ID=access-key-id
export AWS_SECRET_ACCESS_KEY=secret-access-key
export AWS_DEFAULT_REGION=us-east-2

# Create EKS cluster (if not created already)
eksctl create cluster --name nxt-devops-cluster --node-type t2.micro --region us-east-2

# Set kubeconfig context
aws eks update-kubeconfig --name nxt-devops-cluster --region us-east-2

# Deploy the application to EKS
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
