output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value =[aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "db_security_group_id" {
  value = aws_security_group.db_sg.id
}
