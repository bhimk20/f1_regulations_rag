output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "sg_lambda_id" {
  description = "Security group ID for Lambdas"
  value       = aws_security_group.lambda.id
}

output "sg_database_id" {
  description = "Security group ID for the RDS database"
  value       = aws_security_group.database.id
}
