resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = "${var.enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = "${var.dhcp_options_domain_name_servers}"
  ntp_servers          = "${var.dhcp_options_ntp_servers}"
  netbios_name_servers = "${var.dhcp_options_netbios_name_servers}"
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

resource "aws_internet_gateway" "igw" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id           = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags, var.public_route_table_tags, map("Name", format("%s-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${map("Name", element(var.public_subnets_names, count.index))}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}