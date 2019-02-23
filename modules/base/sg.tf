// Rules for Bastion
resource "aws_security_group" "bastion" {
  name   = "sg_bastion-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "bastion_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "bastion_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_allowed_ssh}"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_outbound_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

// Rules for DataBase
resource "aws_security_group" "database" {
  name   = "sg_database-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "database_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "database_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.database.id}"
}

resource "aws_security_group_rule" "database_inbound_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.webserver.id}"
  security_group_id        = "${aws_security_group.database.id}"
}

resource "aws_security_group_rule" "database_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.database.id}"
}

resource "aws_security_group_rule" "database_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.database.id}"
}

// Rules for WebServer
resource "aws_security_group" "webserver" {
  name   = "sg_webserver-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "webserver_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "webserver_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_outbound_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.database.id}"
  security_group_id        = "${aws_security_group.webserver.id}"
}