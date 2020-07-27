# Terraform AWS Uploads Bucket (S3 Bucket + CloudFront Distribution)

## Usage

```tf
data "aws_acm_certificate" "example" {
  domain   = "*.example.com"
  statuses = ["ISSUED"]
}

module "example_uploads" {
  source = "github.com/oowlish/terraform-aws-uploads-bucket?ref=master"

  name = "example"

  forbidden_files = ["**/*.php"]
  
  cloudfront_aliases             = ["uploads.example.com"]
  cloudfront_price_class         = "PriceClass_All"
  cloudfront_acm_certificate_arn = data.aws_acm_certificate.arn

  tags = {
    Terraform = "true
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudfront\_acm\_certificate\_arn | The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. The ACM certificate must be in US-EAST-1. | `string` | `""` | no |
| cloudfront\_aliases | CNAMEs for this CloudFront. | `list(string)` | n/a | yes |
| cloudfront\_price\_class | The price class for this CloudFront. One of PriceClass\_All, PriceClass\_200, PriceClass\_100. | `string` | `"PriceClass_100"` | no |
| forbidden\_files | A list of file to deny access for. | `list(string)` | `[]` | no |
| name | Name to be used on all the resources as identifier. | `string` | n/a | yes |
| tags | A map of tags to assign to the resources. | `map(string)` | `{}` | no |
