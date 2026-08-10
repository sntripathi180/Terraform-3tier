locals {
    name_prefix = "${var.project_name}-${var.environment}"
    nat_gateway_count = var.single_nat_gateway ? 1 : length(var.azs)
}


resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-vpc"
    })
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-igw"
    })
}


resource "aws_subnet" "public" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]
    map_public_ip_on_launch = true

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-public-${var.azs[count.index]}"
        Tier = "public"
    })
}


resource "aws_subnet" "frontend" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.frontend_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-frontend-${var.azs[count.index]}"
        Tier = "frontend-private"
    })

}

resource "aws_subnet" "backend" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.backend_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-backend-${var.azs[count.index]}"
        Tier = "backend-private"
    })

}


resource "aws_subnet" "db" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.db_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]

    tags =  merge(var.tags,{
        Name = "${local.name_prefix}-db-${var.azs[count.index]}"
        Tier = "db-private"
    })
}

resource "aws_subnet" "mgmt" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.mgmt_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-mgmt-${var.azs[count.index]}"
        Tier = "management-private"
    })
}

resource "aws_eip" "nat" {
    count = local.nat_gateway_count
    domain = "vpc"
    tags = merge(var.tags,{
        Name = "${local.name_prefix}-nat-eip-${count.index}"
    })

    depends_on = [aws_internet_gateway.igw]
}


resource "aws_nat_gateway" "nat" {
    count = local.nat_gateway_count
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    tags = merge(var.tags,{
        Name = "${local.name_prefix}-nat-${var.azs[count.index]}"
    })

    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    
    tags = merge(var.tags,{
        Name = "${local.name_prefix}-public-rt"
    })
}

resource "aws_route_table_association" "public" {
    count = length(var.azs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat[0].id : aws_nat_gateway. nat[count.index].id
    }

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-private-rt-${var.azs[count.index]}"
    })
}

resource "aws_route_table_association" "frontend" {
    count = length(var.azs)
    subnet_id = aws_subnet.frontend[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "backend" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "db" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_route_table_association" "mgmt" {
    count = length(var.azs)
    subnet_id = aws_subnet.mgmt[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}


resource "aws_vpc_endpoint" "s3" {
    count = var.enable_s3_vpc_endpoint ? 1 : 0
    vpc_id = aws_vpc.main.id 
    service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
    vpc_endpoint_type = "Gateway"

    route_table_ids = concat(
        [aws_route_table.public.id],
        aws_route_table.private[*].id
    )

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-s3-enpoint"
    })
}

data "aws_region" "current" {}
