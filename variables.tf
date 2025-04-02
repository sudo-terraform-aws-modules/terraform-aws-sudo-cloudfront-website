variable "domain_name" {
  type        = string
  description = "Specify the domain to host on cloudfront"
}
variable "zone_name" {
  type        = string
  description = "Specify the domain to host on cloudfront"
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
  description = "(optional) describe your variable"
  default     = ""
}

variable "acl" {
  type = string
  description = "(optional) acl for objects"
  default = "private"
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