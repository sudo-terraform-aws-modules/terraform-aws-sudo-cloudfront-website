# terraform-aws-sudo-cloudfront-website

This simple module deploys a Static website based on cloudfront + s3.

This uses a sudo acm submodule.

Example:
The below example will setup the s3 bucket and cloud front distribution. It will also create an ACM certificate.
It will also copy the files from source directory to s3 bucket.

```hcl
module "website" {
  source      = "terraform-sudo-modules/aws/cloudfront"
  zone_name = "sudoconsultants.com"
  domain_name = "testwebsite.sudoconsultants.com"
  source_directory = "public"
  acl = "public-read"
}
```
