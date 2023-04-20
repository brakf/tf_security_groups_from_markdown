##add security group with random values
resource "aws_security_group" "sg_test1" {
  name        = "sg_test1"
  description = "Security group for sg_test1"
  vpc_id      = "vpc-9def69f7"
}

resource "aws_ssm_parameter" "dynamic_sg" {
  name  = "/security_groups/external_server"
  value = aws_security_group.sg_test1.id # Replace with the appropriate value
  type  = "String"
}

module "security_groups" {
  source             = "../"
  vpc_id             = "vpc-9def69f7"
  markdown_file_path = "${path.module}/security_groups_example.md"

  depends_on = [
    aws_ssm_parameter.dynamic_sg
  ]
}
