output "project_id" {
  description = "Railway project ID"
  value       = railway_project.openclaw.id
}

# Note: The public service URL is assigned by Railway at deploy time and is
# not directly available as a Terraform attribute. After `terraform apply`,
# find the URL in the Railway dashboard or via `railway status`. You can
# optionally add a custom domain via `railway_custom_domain` resource.
