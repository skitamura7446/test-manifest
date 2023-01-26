terraform {
  backend "local" {
    path = "${REMOTE_STATE_DIR}/terraform.tfstate"
  }
}

locals {
  rosa_route_table = [
    "$ROSA_ROUTE_TABLE_1_ID",
    "$ROSA_ROUTE_TABLE_2_ID",
    "$ROSA_ROUTE_TABLE_3_ID",
  ]
  db_route_table = [
    "$DB_ROUTE_TABLE_1_ID",
    "$DB_ROUTE_TABLE_2_ID",
  ]
}

provider "aws" {
  alias  = "rosa"
  region = "$ROSA_REGION"
}

provider "aws" {
  alias  = "db"
  region = "$DB_REGION"
}

resource "aws_vpc_peering_connection" "rosa-db-connection" {
  provider    = aws.rosa
  peer_vpc_id = "$DB_VPC_ID"
  vpc_id      = "$ROSA_VPC_ID"
  peer_region = "$DB_REGION"
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.db
  vpc_peering_connection_id = aws_vpc_peering_connection.rosa-db-connection.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "rosa_route" {
  provider                  = aws.rosa
  for_each                  = toset(local.rosa_route_table)
  route_table_id            = each.value
  destination_cidr_block    = "$DB_VPC_CIDR"
  vpc_peering_connection_id = aws_vpc_peering_connection.rosa-db-connection.id
}

resource "aws_route" "db_route" {
  provider                  = aws.db
  for_each                  = toset(local.db_route_table)
  route_table_id            = each.value
  destination_cidr_block    = "$ROSA_VPC_CIDR"
  vpc_peering_connection_id = aws_vpc_peering_connection.rosa-db-connection.id
}


#resource "aws_route_table" "rds-vpc-route-table" {
#  provider = aws.db
#  vpc_id   = "$DB_VPC_ID"
#
#  route {
#    cidr_block                = "$ROSA_VPC_CIDR"
#    vpc_peering_connection_id = aws_vpc_peering_connection.rosa-db-connection.id
#  }
#
#  tags = {
#    Name = "rds-vpc-route-table"
#  }
#}
#
#
#resource "aws_route_table" "rosa-vpc-route-table" {
#  provider = aws.rosa
#  vpc_id   = "$ROSA_VPC_ID"
#
#  route {
#    cidr_block                = "$DB_VPC_CIDR"
#    vpc_peering_connection_id = aws_vpc_peering_connection.rosa-db-connection.id
#  }
#
#  tags = {
#    Name = "rosa-vpc-route-table"
#  }
#}
