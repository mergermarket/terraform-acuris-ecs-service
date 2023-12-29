locals {
  service_name      = "${var.env}-${var.release["component"]}"
  full_service_name = "${local.service_name}${var.name_suffix}"
}

module "ecs_update_monitor" {
  source  = "mergermarket/ecs-update-monitor/acuris"
  version = "2.3.5"

  cluster = var.ecs_cluster
  service = module.service.name
  taskdef = module.taskdef.arn
  is_test = var.is_test
  timeout = var.deployment_timeout
}

module "service" {
  source  = "mergermarket/load-balanced-ecs-service-no-target-group/acuris"
  version = "2.2.7"

  name                                  = local.full_service_name
  cluster                               = var.ecs_cluster
  task_definition                       = module.taskdef.arn
  container_name                        = "${var.release["component"]}${var.name_suffix}"
  container_port                        = var.port
  desired_count                         = var.desired_count
  target_group_arn                      = var.target_group_arn
  multiple_target_group_arns            = var.multiple_target_group_arns
  deployment_minimum_healthy_percent    = var.deployment_minimum_healthy_percent
  deployment_maximum_percent            = var.deployment_maximum_percent
  network_configuration_subnets         = var.network_configuration_subnets
  network_configuration_security_groups = var.network_configuration_security_groups
  pack_and_distinct                     = var.pack_and_distinct
  health_check_grace_period_seconds     = var.health_check_grace_period_seconds
}

module "taskdef" {
  source  = "mergermarket/task-definition-with-task-role/acuris"
  version = "2.1.0"

  family                = local.full_service_name
  container_definitions = [module.service_container_definition.rendered]
  policy                = var.task_role_policy
  assume_role_policy    = var.assume_role_policy
  volume                = var.taskdef_volume
  env                   = var.env
  release               = var.release
  network_mode          = var.network_mode
  is_test               = var.is_test
}

module "service_container_definition" {
  source  = "mergermarket/ecs-container-definition/acuris"
  version = "2.2.0"

  name                = "${var.release["component"]}${var.name_suffix}"
  image               = "${var.image_id != "" ? var.image_id : var.release["image_id"]}"
  cpu                 = var.cpu
  privileged          = var.privileged
  memory              = var.memory
  stop_timeout        = var.stop_timeout
  container_port      = var.port
  nofile_soft_ulimit  = var.nofile_soft_ulimit
  mountpoint          = var.container_mountpoint
  port_mappings       = var.container_port_mappings
  application_secrets = var.application_secrets
  platform_secrets    = var.platform_secrets

  container_env = merge(
    {
      "LOGSPOUT_CLOUDWATCHLOGS_LOG_GROUP_STDOUT" = "${local.full_service_name}-stdout"
      "LOGSPOUT_CLOUDWATCHLOGS_LOG_GROUP_STDERR" = "${local.full_service_name}-stderr"
      "STATSD_HOST"                              = "172.17.42.1"
      "STATSD_PORT"                              = "8125"
      "STATSD_ENABLED"                           = "true"
      "ENV_NAME"                                 = var.env
      "COMPONENT_NAME"                           = var.release["component"]
      "VERSION"                                  = var.release["version"]
    },
    var.common_application_environment,
    var.application_environment,
    var.secrets,
  )

  labels = merge(
    {
      "component" = var.release["component"]
      "env"       = var.env
      "team"      = var.release["team"]
      "version"   = var.release["version"]
    },
    var.container_labels,
  )
}

resource "aws_cloudwatch_log_group" "stdout" {
  name              = "${local.full_service_name}-stdout"
  retention_in_days = "7"
}

resource "aws_cloudwatch_log_group" "stderr" {
  name              = "${local.full_service_name}-stderr"
  retention_in_days = "7"
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis_log_stdout_stream" {
  count           = var.platform_config["datadog_log_subscription_arn"] != "" && var.add_datadog_feed ? 1 : 0
  name            = "kinesis-log-stdout-stream-${local.service_name}"
  destination_arn = var.platform_config["datadog_log_subscription_arn"]
  log_group_name  = "${local.full_service_name}-stdout"
  filter_pattern  = ""
  depends_on      = [aws_cloudwatch_log_group.stdout]
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis_log_stderr_stream" {
  count           = var.platform_config["datadog_log_subscription_arn"] != "" && var.add_datadog_feed ? 1 : 0
  name            = "kinesis-log-stdout-stream-${local.service_name}"
  destination_arn = var.platform_config["datadog_log_subscription_arn"]
  log_group_name  = "${local.full_service_name}-stderr"
  filter_pattern  = ""
  depends_on      = [aws_cloudwatch_log_group.stderr]
}

resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = var.desired_count
  max_capacity       = var.desired_count
  resource_id        = "service/${var.ecs_cluster}/${local.full_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_scheduled_action" "scale_down" {
  count              = var.env != "live" && var.allow_overnight_scaledown ? 1 : 0
  name               = "scale_down-${local.full_service_name}"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(*/30 ${var.overnight_scaledown_start_hour}-${var.overnight_scaledown_end_hour - 1} ? * * *)"

  scalable_target_action {
    min_capacity = var.overnight_scaledown_min_count
    max_capacity = var.overnight_scaledown_min_count
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_back_up" {
  count              = var.env != "live" && var.allow_overnight_scaledown ? 1 : 0
  name               = "scale_up-${local.full_service_name}"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(10 ${var.overnight_scaledown_end_hour} ? * MON-FRI *)"

  scalable_target_action {
    min_capacity = var.desired_count
    max_capacity = var.desired_count
  }
}

resource "aws_appautoscaling_policy" "task_scaling_policy" {
  for_each   = {
    for index, scale in var.scaling_metrics:
    scale.metric => scale 
  }  
  name               = each.value.name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = each.value.disable_scale_in
    scale_in_cooldown  = each.value.scale_in_cooldown
    scale_out_cooldown = each.value.scale_out_cooldown
    target_value       = each.value.target_value

    predefined_metric_specification {
      predefined_metric_type = each.value.metric
    }
  }
}