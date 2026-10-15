variable "domain_name" {
  type        = string
  description = "Specify the domain to host on cloudfront"
}
variable "zone_name" {
  type        = string
  description = "Route53 hosted zone name for DNS record creation. Defaults to domain_name if not specified."
  default     = null
}
variable "comment" {
  type        = string
  description = "(optional) Add comment for cloudfront distribution"
  default     = "Cloudfront distribution - Managed by SUDO Cloudfront Terraform Module"
}

variable "uri_path" {
  type        = string
  description = "(optional) URI path to publish"
  default     = ""
}

variable "source_file" {
  type        = string
  description = "(optional) source file path to publish on uri_path"
  default     = ""
}
variable "source_directory" {
  type        = string
  description = "(optional) source file path to publish on uri_path"
  default     = ""
}
variable "bucket_name" {
  type        = string
  description = "Override the S3 bucket name. Defaults to <domain_name>-cloudfront-bucket."
  default     = ""
}

variable "acl" {
  type        = string
  description = "ACL for S3 objects uploaded via source_file."
  default     = "private"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources created by this module."
  default     = {}
}

variable "acm_certificate_arn" {
  type        = string
  description = "(optional) ACM certificate ARN"
  default     = ""

}

variable "custom_error_response" {
  description = "One or more custom error response elements"
  type        = any
  default     = {}
}

variable "default_root_object" {
  description = "(optional) Default root object for the distribution"
  type        = string
  default     = "index.html"
}