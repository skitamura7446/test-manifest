resource "aws_vpc_peering_connection" "rosa-db-connection" {
  peer_vpc_id = "$DB_VPC_ID"
  vpc_id      = "$ROSA_VPC_ID"
  auto_accept = true
}

resource "aws_route_table" "rds-vpc-route-table" {
  vpc_id = "$DB_VPC_ID"

  route {
    cidr_block                = "$ROSA_VPC_CIDR"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.rosa-db-connection.id}"
  }

  tags = {
    Name = "rds-vpc-route-table"
  }
}


resource "aws_route_table" "rosa-vpc-route-table" {
  vpc_id = "$ROSA_VPC_ID"

  route {
    cidr_block                = "$DB_VPC_CIDR"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.rosa-db-connection.id}"
  }

  tags = {
    Name = "rosa-vpc-route-table"
  }
}
