# EC2 实例模块
# 先获取 Amazon Linux 2 的最新 AMI ID（按 Region 自动找）
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # 官方 Amazon 拥有者ID
}

# 创建 EC2 实例
resource "aws_instance" "api_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.api_security_group_id]

  key_name = aws_key_pair.main.key_name

  tags = merge(var.common_tags, {
    Name = "api-server-${var.env}"
  })
}
