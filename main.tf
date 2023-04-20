resource "aws_security_group" "dynamic_sg" {
  for_each = local.extracted

  name        = each.key
  description = "Security group: ${each.key}"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "dynamic_sg_rule" {
  for_each = { for rule in local.flattened_rules : "${rule.source}-${rule.target}-${rule.port}" => rule }

  security_group_id = aws_security_group.dynamic_sg[each.value.target].id

  type                     = "ingress"
  from_port                = tonumber(each.value.port)
  to_port                  = tonumber(each.value.port)
  protocol                 = "tcp"
  source_security_group_id = length(regexall("cidr\\((.*)\\)", each.value.source)) == 0 ? (length(regexall("ssm\\(.*\\)", each.value.source)) > 0 ? data.aws_ssm_parameter.dynamic_sg[each.value.source].value : aws_security_group.dynamic_sg[each.value.source].id) : null
  cidr_blocks              = length(regexall("cidr\\((.*)\\)", each.value.source)) > 0 ? [regexall("cidr\\((.*)\\)", each.value.source).0[0]] : null

}

resource "aws_security_group_rule" "dynamic_sg_egress" {
  for_each = aws_security_group.dynamic_sg

  security_group_id = each.value.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}



data "aws_ssm_parameter" "dynamic_sg" {
  for_each = toset([for rule in local.flattened_rules : rule.source if length(regexall("ssm\\(.*\\)", rule.source)) > 0])
  name     = regexall("ssm\\((.*)\\)", each.value).0[0]
}

