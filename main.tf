module "ec2" {
  source         = "./modules/ec2"
  ami_id         = var.ami_id
  instance_type  = var.instance_type
}

module "rds" {
  source      = "./modules/rds"
  db_name     = var.db_name
  db_username = var.db_username
}

module "s3_1" {
  source      = "./modules/s3"
  bucket_name = "ankit-app-bucket-1"
}

module "s3_2" {
  source      = "./modules/s3"
  bucket_name = "ankit-app-bucket-2"
}

module "lambda1" {
  source        = "./modules/lambda"
  function_name = "lambda-1"
}

module "lambda2" {
  source        = "./modules/lambda"
  function_name = "lambda-2"
}

module "secrets" {
  source         = "./modules/secrets"
  rds_endpoint   = module.rds.endpoint
  rds_username   = var.db_username
  rds_password   = module.rds.password
}