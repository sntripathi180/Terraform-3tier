output "vpc_id" {
    description = "ID of the VPC"
    value = aws_vpc.main.id
}

output "vpc_cidr" {
    description = "CIDR block of the VPC"
    value = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
    description = "ID of the Internet Gateway"
    value = aws_internet_gateway.igw.id
}


output "nat_gateway_ids" {
    description = "IDs of the NAT Gateway(s)"
    value = aws_nat_gateway.nat[*].id
}

output "public_subnet_ids" {
    description = "IDs of the public subnets (one per AZ)"
    value = aws_subnet.public[*].id
}

output "frontend_subnet_ids" {
    description = "ID of the frontend-tier private subnet"
    value = aws_subnet.frontend[*].id
}

output "backend_subnet_ids" {
    description = "ID of the backend-tier private subnet"
    value = aws_subnet.backend[*].id
}

output "db_subnet_ids" {
    description = "IDs of the db-tier private subnets"
    value = aws_subnet.db[*].id
}

output "mgmt_subnet_ids" {
    description = "IDs of the management-tier private subnets"
    value = aws_subnet.mgmt[*].id
}

output "public_route_table_id" {
    description = "IDs of the private routes tables"
    value = aws_route_table.private[*].id
}

output "availability_zones" {
    description = "AZs this network was developed into "
    value = var.azs
}