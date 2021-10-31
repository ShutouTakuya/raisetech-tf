# -------------------------------------
# data
# -------------------------------------
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.*.s3"
}

# 最新のAmazon Linux2のAMI IDを取得(Webサーバー)
# data "aws_ami" "web_server" {
#   most_recent = true
#   owners      = ["self", "amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# # 最新のAmazon Linux2のAMI IDを取得(APサーバー)
# data "aws_ami" "ap_server" {
#   most_recent = true
#   owners      = ["self", "amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }
