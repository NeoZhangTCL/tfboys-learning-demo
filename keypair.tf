# 生成 RSA 私钥
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 在 AWS 中创建密钥对，使用生成的公钥
resource "aws_key_pair" "main" {
  key_name   = "${var.env}-keypair"
  public_key = tls_private_key.main.public_key_openssh

  tags = merge(local.common_tags, {
    Name = "${var.env}-keypair"
  })
}

# 将私钥保存到本地文件
resource "local_file" "private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${path.module}/keys/${var.env}-keypair.pem"
  file_permission = "0600"  # 只有所有者可读写
}

# 确保 keys 目录存在
resource "local_file" "keys_dir" {
  content  = ""
  filename = "${path.module}/keys/.gitkeep"
}
