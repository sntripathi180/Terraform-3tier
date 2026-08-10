output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids

}

output "frontend_subnet_ids" {
  value = module.networking.frontend_subnet_ids

}

output "backend_subnet_ids" {
  value = module.networking.backend_subnet_ids
}

output "db_subnet_ids" {
  value = module.networking.db_subnet_ids
}

output "mgmt_subnet_ids" {
  value = module.networking.mgmt_subnet_ids
}

output "nat_gateway_id" {
  value = module.networking.nat_gateway_ids
}