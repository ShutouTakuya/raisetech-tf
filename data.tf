# -------------------------------------
# data
# -------------------------------------
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}
# data "http" "ifconfig" {
#   url = "http://checkip.amazonaws.com/"
# }

data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.*.s3"
}