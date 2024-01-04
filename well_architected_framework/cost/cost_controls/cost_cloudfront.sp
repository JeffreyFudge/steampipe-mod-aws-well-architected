locals {
  cloudfront_common_tags = merge(local.well_architected_framework_cost_common_tags, {
    service = "AWS/CloudFront"
  })
}

benchmark "cloudfront" {
  title         = "Cost Optimization: CloudFront"
  description   = "CloudFront distribution pricing should be reviewed an optional edge locations removed."

  children = [
    control.cloudfront_distribution_pricing_class
  ]

  tags = merge(local.cloudfront_common_tags, {
    type = "Benchmark"
  })
}

control "cloudfront_distribution_pricing_class" {
  title         = "CloudFront distribution pricing class should be reviewed"
  description   = "CloudFront distribution pricing class should be reviewed. Price Classes let you reduce your delivery prices by excluding Amazon CloudFront’s more expensive edge locations from your Amazon CloudFront distribution."
  severity      = "low"

  tags = merge(local.cloudfront_common_tags, {
    class = "managed"
  })

  sql = <<-EOQ
    select
      id as resource,
      case
        when price_class = 'PriceClass_All' then 'info'
        else 'ok'
      end as status,
      title || ' has ' || price_class || '.'
      as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      aws_cloudfront_distribution;
  EOQ

}
