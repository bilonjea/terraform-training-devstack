output "instance_id" {
  value = aws_instance.devstack.id
}

output "public_ip" {
  value = aws_instance.devstack.public_ip
}

output "horizon_url" {
  value = "http://${aws_instance.devstack.public_ip}/"
}

output "ssh_command" {
  value = "ssh -i <PRIVATE_KEY_PATH> ubuntu@${aws_instance.devstack.public_ip}"
}

output "devstack_admin_username" {
  value = "admin"
}

output "devstack_admin_password" {
  value     = random_password.admin.result
  sensitive = true
}

output "devstack_install_log" {
  value = "/opt/stack/logs/stack.sh.log"
}
