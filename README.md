# terraform-acuris-ecs-service

[![Test](https://github.com/mergermarket/terraform-acuris-ecs-service/actions/workflows/test.yml/badge.svg)](https://github.com/mergermarket/terraform-acuris-ecs-service/actions/workflows/test.yml)

An ECS service with an ALB target group, suitable for routing to from an ALB.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_update_monitor"></a> [ecs\_update\_monitor](#module\_ecs\_update\_monitor) | mergermarket/ecs-update-monitor/acuris | 2.3.5 |
| <a name="module_service"></a> [service](#module\_service) | mergermarket/load-balanced-ecs-service-no-target-group/acuris | 2.2.7 |
| <a name="module_service_container_definition"></a> [service\_container\_definition](#module\_service\_container\_definition) | mergermarket/ecs-container-definition/acuris | 2.2.0 |
| <a name="module_taskdef"></a> [taskdef](#module\_taskdef) | mergermarket/task-definition-with-task-role/acuris | 2.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.task_scaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.scale_back_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.stderr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.stdout](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.kinesis_log_stderr_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_log_subscription_filter.kinesis_log_stdout_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_datadog_feed"></a> [add\_datadog\_feed](#input\_add\_datadog\_feed) | Flag to control adding subscription filter to CW loggroup | `bool` | `true` | no |
| <a name="input_allow_overnight_scaledown"></a> [allow\_overnight\_scaledown](#input\_allow\_overnight\_scaledown) | Allow service to be scaled down | `bool` | `true` | no |
| <a name="input_application_environment"></a> [application\_environment](#input\_application\_environment) | Environment specific parameters passed to the container | `map(string)` | `{}` | no |
| <a name="input_application_secrets"></a> [application\_secrets](#input\_application\_secrets) | A list of application specific secret names that can be found in aws secrets manager | `list(string)` | `[]` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | A valid IAM policy for assuming roles - optional | `string` | `""` | no |
| <a name="input_common_application_environment"></a> [common\_application\_environment](#input\_common\_application\_environment) | Environment parameters passed to the container for all environments | `map(string)` | `{}` | no |
| <a name="input_container_labels"></a> [container\_labels](#input\_container\_labels) | Additional docker labels to apply to the container. | `map(string)` | `{}` | no |
| <a name="input_container_mountpoint"></a> [container\_mountpoint](#input\_container\_mountpoint) | Map containing 'sourceVolume', 'containerPath' and 'readOnly' (optional) to map a volume into a container. | `map(string)` | `{}` | no |
| <a name="input_container_port_mappings"></a> [container\_port\_mappings](#input\_container\_port\_mappings) | JSON document containing an array of port mappings for the container defintion - if set port is ignored (optional). | `string` | `""` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU unit reservation for the container | `string` | n/a | yes |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The maximumPercent parameter represents an upper limit on the number of your service's tasks that are allowed in the RUNNING or PENDING state during a deployment, as a percentage of the desiredCount (rounded down to the nearest integer). | `string` | `"200"` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The minimumHealthyPercent represents a lower limit on the number of your service's tasks that must remain in the RUNNING state during a deployment, as a percentage of the desiredCount (rounded up to the nearest integer). | `string` | `"100"` | no |
| <a name="input_deployment_timeout"></a> [deployment\_timeout](#input\_deployment\_timeout) | Timeout to wait for the deployment to be finished [seconds]. | `number` | `600` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running. | `string` | `"3"` | no |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | The ECS cluster | `string` | `"default"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `any` | n/a | yes |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Default 0. | `string` | `"0"` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | ECR image\_id for the ecs container | `string` | `""` | no |
| <a name="input_is_test"></a> [is\_test](#input\_is\_test) | For testing only. Stops the call to AWS for sts | `bool` | `false` | no |
| <a name="input_log_subscription_arn"></a> [log\_subscription\_arn](#input\_log\_subscription\_arn) | To enable logging to a kinesis stream | `string` | `""` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The memory reservation for the container in megabytes | `string` | n/a | yes |
| <a name="input_multiple_target_group_arns"></a> [multiple\_target\_group\_arns](#input\_multiple\_target\_group\_arns) | Mutiple target group ARNs to allow connection to multiple loadbalancers | `list(any)` | `[]` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Set a suffix that will be applied to the name in order that a component can have multiple services per environment | `string` | `""` | no |
| <a name="input_network_configuration_security_groups"></a> [network\_configuration\_security\_groups](#input\_network\_configuration\_security\_groups) | needed for network\_mode awsvpc | `list(any)` | `[]` | no |
| <a name="input_network_configuration_subnets"></a> [network\_configuration\_subnets](#input\_network\_configuration\_subnets) | needed for network\_mode awsvpc | `list(any)` | `[]` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The Docker networking mode to use for the containers in the task | `string` | `"bridge"` | no |
| <a name="input_nofile_soft_ulimit"></a> [nofile\_soft\_ulimit](#input\_nofile\_soft\_ulimit) | The soft ulimit for the number of files in container | `string` | `"4096"` | no |
| <a name="input_overnight_scaledown_end_hour"></a> [overnight\_scaledown\_end\_hour](#input\_overnight\_scaledown\_end\_hour) | When to bring service back to full strength (Hour in UTC) | `string` | `"06"` | no |
| <a name="input_overnight_scaledown_min_count"></a> [overnight\_scaledown\_min\_count](#input\_overnight\_scaledown\_min\_count) | Minimum task count overnight | `string` | `"0"` | no |
| <a name="input_overnight_scaledown_start_hour"></a> [overnight\_scaledown\_start\_hour](#input\_overnight\_scaledown\_start\_hour) | From when a service can be scaled down (Hour in UTC) | `string` | `"22"` | no |
| <a name="input_pack_and_distinct"></a> [pack\_and\_distinct](#input\_pack\_and\_distinct) | Enable distinct instance and task binpacking for better cluster utilisation. Enter 'true' for clusters with auto scaling groups. Enter 'false' for clusters with no ASG and instant counts less than or equal to desired tasks | `string` | `"false"` | no |
| <a name="input_platform_config"></a> [platform\_config](#input\_platform\_config) | Platform configuration | `map(string)` | `{}` | no |
| <a name="input_platform_secrets"></a> [platform\_secrets](#input\_platform\_secrets) | A list of common secret names for "the platform" that can be found in secrets manager | `list(string)` | `[]` | no |
| <a name="input_port"></a> [port](#input\_port) | The port that container will be running on | `string` | n/a | yes |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | Gives the container privileged access to the host | `bool` | `false` | no |
| <a name="input_release"></a> [release](#input\_release) | Metadata about the release | `map(string)` | n/a | yes |
| <a name="input_scaling_metrics"></a> [scaling\_metrics](#input\_scaling\_metrics) | A list of maps defining the scaling of the services tasks - for more info see below | `list(any)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret credentials fetched using credstash | `map(string)` | `{}` | no |
| <a name="input_stop_timeout"></a> [stop\_timeout](#input\_stop\_timeout) | The duration is seconds to wait before the container is forcefully killed. Default 30s, max 120s. | `string` | `"none"` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | The ALB target group for the service. | `string` | `""` | no |
| <a name="input_task_role_policy"></a> [task\_role\_policy](#input\_task\_role\_policy) | IAM policy document to apply to the tasks via a task role | `string` | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:GetCallerIdentity\",\n      \"Effect\": \"Allow\",\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"` | no |
| <a name="input_taskdef_volume"></a> [taskdef\_volume](#input\_taskdef\_volume) | Map containing 'name' and 'host\_path' used to add a volume mapping to the taskdef. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_service_name"></a> [full\_service\_name](#output\_full\_service\_name) | n/a |
| <a name="output_stderr_name"></a> [stderr\_name](#output\_stderr\_name) | n/a |
| <a name="output_stdout_name"></a> [stdout\_name](#output\_stdout\_name) | n/a |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | n/a |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | n/a |
| <a name="output_taskdef_arn"></a> [taskdef\_arn](#output\_taskdef\_arn) | n/a |

## Scaling Metrics

Setting this variable to a lis tof maps.  Each map defines a seperate scaling policy

| Param | Description |
|-------|-------------|
| name | (Required) Must be unique |
| metric | (Required) Name of the metric to use for scaling - see below for allowed values|
| target_value | (Required) Value of the above metric that scaling will maintain |
| disable_scale_in | (Optional) Whether scale in by the target tracking policy is disabled. If the value is true, scale in is disabled and the target tracking policy won't remove capacity from the scalable resource.|
| scale_in_cooldown | (Optional) Amount of time, in seconds, after a scale in activity completes before another scale in activity can start |
| scale_out_cooldown |  (Optional) Amount of time, in seconds, after a scale out activity completes before another scale out activity can start. |

### Allowed Metrics
* ECSServiceAverageCPUUtilization
* ECSServiceAverageMemoryUtilization
* ALBRequestCountPerTarget

### Example
```
  scaling_metrics = [
    {
      name               = "cpu"
      metric             = "ECSServiceAverageCPUUtilization"
      target_value       = 10
      disable_scale_in   = false
      scale_in_cooldown  = 180
      scale_out_cooldown = 90
    },
    {
      name               = "memory"
      metric             = "ECSServiceAverageMemoryUtilization"
      target_value       = 10
      disable_scale_in   = false
      scale_in_cooldown  = 180
      scale_out_cooldown = 90
    }
  ]
```
<!-- END_TF_DOCS -->