locals {
  well_architected_framework_cost_common_tags = merge(local.well_architected_framework_common_tags, {
    pillar_id = "Cost"
  })
}

benchmark "well_architected_framework_cost" {
  title       = "EC2 Cost Optimization"
  description = "The security pillar focuses on protecting information and systems. Key topics include confidentiality and integrity of data, managing user permissions, and establishing controls to detect security events."
  children = [
    benchmark.cost_ec2
  ]

  tags = local.well_architected_framework_cost_common_tags
}
