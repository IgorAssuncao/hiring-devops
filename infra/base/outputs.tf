output "main_ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "main_ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "main_ecs_asg_name" {
  value = aws_autoscaling_group.this.name
}

// output "main_ecs_elb_name" {
//   value = aws_elb.ecs_service.name
// }
