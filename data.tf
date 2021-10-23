# # -------------------------------------
# # data
# # -------------------------------------
# data "http" "ifconfig" {
#   url = "http://ipv4.icanhazip.com/"
# }
# # data "http" "ifconfig" {
# #   url = "http://checkip.amazonaws.com/"
# # }

# data "aws_prefix_list" "s3_pl" {
#   name = "com.amazonaws.*.s3"
# }

# data "aws_ami" "app" {
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