output "endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.this.id
}

output "client_cert_paths" {
  description = "Local file paths to each client's certificate"
  value       = { for name, f in local_sensitive_file.client_cert : name => f.filename }
}

output "client_key_paths" {
  description = "Local file paths to each client's private key"
  value       = { for name, f in local_sensitive_file.client_key : name => f.filename }
}

output "ca_cert_path" {
  value = local_sensitive_file.ca_cert.filename
}

output "ovpn_export_command" {
  description = "Run this AWS CLI command to download the base .ovpn config, then splice in the cert/key files above"
  value       = "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.this.id} --output text > client-config-base.ovpn"
}
