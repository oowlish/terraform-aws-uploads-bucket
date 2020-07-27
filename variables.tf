variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier."
}

variable "forbidden_files" {
  type        = list(string)
  default     = []
  description = "A list of file to deny access for."
}

variable "cloudfront_aliases" {
  type        = list(string)
  description = "CNAMEs for this CloudFront."
}

variable "cloudfront_price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "The price class for this CloudFront. One of PriceClass_All, PriceClass_200, PriceClass_100."
}

variable "cloudfront_acm_certificate_arn" {
  type        = string
  default     = ""
  description = "The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. The ACM certificate must be in US-EAST-1."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resources."
}
