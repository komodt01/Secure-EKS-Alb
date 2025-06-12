variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "route53_zone_name" {
  description = "The name of the Route 53 public hosted zone (e.g., eks-sec.lab)"
  type        = string
}