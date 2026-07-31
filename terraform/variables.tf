variable "aws_region" {
  description = "The AWS region to deploy EKS cluster"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment for the EKS cluster (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "jerney-eks"
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}