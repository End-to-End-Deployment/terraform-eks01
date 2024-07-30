output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
  condition   = module.eks.cluster_id != null
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
  condition   = module.eks.cluster_endpoint != null
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
  condition   = module.eks.cluster_security_group_id != null
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  condition   = module.eks.oidc_provider_arn != null
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  condition   = module.eks.cluster_certificate_authority_data != null
}

output "kubeconfig" {
  value       = module.eks.cluster_id != null && module.eks.cluster_endpoint != null && module.eks.cluster_certificate_authority_data != null ? templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_endpoint                    = module.eks.cluster_endpoint,
    cluster_certificate_authority_data  = module.eks.cluster_certificate_authority_data,
    cluster_id                          = module.eks.cluster_id
  }) : null
  sensitive   = true
}

output "kubeconfig_yaml" {
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
  name: ${module.eks.cluster_id}
contexts:
- context:
    cluster: ${module.eks.cluster_id}
    user: aws
  name: ${module.eks.cluster_id}
current-context: ${module.eks.cluster_id}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${module.eks.cluster_id}
      # Uncomment the following lines for EKS clusters on AWS GovCloud (US) or China regions
      # env:
      #   - name: AWS_STS_REGIONAL_ENDPOINTS
      #     value: regional
EOT
  sensitive = true
}
