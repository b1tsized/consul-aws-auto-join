# SECUTIY GROUPS

resource "aws_security_group" "consul-sg" {

  name        = "consul-sg"
  vpc_id      = var.vpc-id
  description = "Sec Group for Consul Servers"

}

resource "aws_security_group_rule" "consul-ingress-rules" {

  count = length(var.consul-sg-ingress-rules)

  type              = "ingress"
  from_port         = var.consul-sg-ingress-rules[count.index].from_port
  to_port           = var.consul-sg-ingress-rules[count.index].to_port
  protocol          = var.consul-sg-ingress-rules[count.index].protocol
  cidr_blocks       = [var.consul-sg-ingress-rules[count.index].cidr_block]
  description       = var.consul-sg-ingress-rules[count.index].description
  security_group_id = aws_security_group.consul-sg.id

}

resource "aws_security_group_rule" "consul-egress-rules" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.consul-sg.id

}

# IAM

resource "aws_iam_role" "consul-join" {
  name               = "consul-join"
  assume_role_policy = "${file("${path.module}/template/policies/assume-role.json")}"
}

resource "aws_iam_policy" "consul-join" {
  name        = "consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/template/policies/describe-instances.json")}"
}

resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}

resource "aws_iam_instance_profile" "consul-join" {
  name  = "consul-join"
  role = aws_iam_role.consul-join.name
}

# AWS INSTANCES

resource "aws_instance" "consul-servers" {
  count = var.consul-servers

  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.consul-sg.id]
  key_name                    = var.key-name
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  user_data = templatefile("${path.module}/template/consul/consul-install.tftpl", {consul_version = "1.11.2", server_name = "${var.data-center}-server${count.index + 1}", config =<<EOF
"node_name": "${var.data-center}-server-${count.index + 1}",
"bootstrap_expect": ${var.consul-servers},
"server": true,
EOF
    })
  tags = merge({
    "Name" = "consul-sv${count.index + 1}" },
    var.required-tags,
  )
}

resource "aws_instance" "consul-clients" {
  count = var.consul-clients

  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.consul-sg.id]
  key_name                    = var.key-name
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  user_data = templatefile("${path.module}/template/consul/consul-install.tftpl", {consul_version = "1.11.2", server_name = "${var.data-center}-client${count.index + 1}", config = <<EOF
  "node_name": "${var.data-center}-client-${count.index + 1}",
  "server": false,
  EOF
  })
  tags = merge({
    "Name" = "consul-client${count.index + 1}" },
    var.required-tags,
  )
}


# AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}