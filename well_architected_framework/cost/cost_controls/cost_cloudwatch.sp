
locals {
  cloudwatch_common_tags = merge(local.well_architected_framework_cost_common_tags, {
    service = "AWS/CloudWatch"
  })
}

benchmark "cloudwatch" {
  title         = "Cost Optimization: CloudWatch"
  description   = "Actively manage the retention of your Cloudtrail logs."

  children = [
    control.cw_log_group_retention,
    control.cw_log_stream_unused
  ]

  tags = merge(local.cloudwatch_common_tags, {
    type = "Benchmark"
  })
}

control "cw_log_group_retention" {
  title       = "CloudWatch Log Groups retention should be enabled"
  description = "Log groups without a retention period are retained indefinitely."
  severity    = "low"

  tags = merge(local.cloudwatch_common_tags, {
    class = "managed"
  })
  sql = <<-EOQ
    select
      arn as resource,
      case
        when retention_in_days is null then 'alarm'
        else 'ok'
      end as status,
      case
        when retention_in_days is null then name || ' does not have data retention enabled.'
        else name || ' is set to ' || retention_in_days || ' day retention.'
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      aws_cloudwatch_log_group;
  EOQ
}

control "cw_log_stream_unused" {
  title       = "Unused log streams should be removed if not required"
  description = "Unnecessary log streams should be deleted for storage cost savings."
  severity    = "low"

  tags = merge(local.cloudwatch_common_tags, {
    class = "unused"
  })
  sql = <<-EOQ
  select
    count(*) as count,
    '' as resource,
    case
      when count(*) > 0 then 'alarm' 
	    else 'ok'
    end as status,
    case
      when count(*) > 0 then 'You have ' || count(*) || ' logs over 90 days old.'
	    else 'You have 0 logs over 90 days old.'
    end as reason
   from aws_cloudwatch_log_stream 
   where date_part('day', now() - last_ingestion_time) > 90
;
  EOQ
}
