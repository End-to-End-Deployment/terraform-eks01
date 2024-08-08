pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['Apply', 'Destroy'], description: 'Select action: Apply or Destroy')
    }
    environment {
        REPO_URL = 'https://github.com/iam-veeramalla/terraform-eks.git'
        TERRAFORM_WORKSPACE = "/var/lib/jenkins/workspace/${JOB_NAME}/"
        ECR_REPO = 'public.ecr.aws/h2w8u3c9/springboot-mysql'
        IMAGE_TAG = "v1.${BUILD_ID}"
        AWS_REGION = 'us-east-1'
        KUBECONFIG = "/var/lib/jenkins/workspace/${JOB_NAME}/kubeconfig"
        KUBECONFIG_CREDENTIALS_ID = 'your-kubeconfig-credentials-id' // Update this with the actual credentials ID
    }
    stages {
        stage('Clone Repository') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: '2ace6162-aeb3-4ad9-9d3d-3f4e8357aa34', url: env.REPO_URL]])
            }
        }
        stage('Terraform Setup') {
            parallel {
                stage('Terraform Init') {
                    steps {
                        sh "cd ${env.TERRAFORM_WORKSPACE} && terraform init"
                    }
                }
                stage('Terraform Validate') {
                    steps {
                        sh "cd ${env.TERRAFORM_WORKSPACE} && terraform validate"
                    }
                }
                stage('Terraform Plan') {
                    steps {
                        sh "cd ${env.TERRAFORM_WORKSPACE} && terraform plan"
                    }
                }
            }
        }
        stage('Approval For Apply') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                input "Do you want to apply Terraform changes?"
            }
        }
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                sh """
                    cd ${env.TERRAFORM_WORKSPACE}
                    terraform apply -auto-approve
                """
            }
        }
        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'Destroy' }
            }
            steps {
                input "Do you want to Terraform Destroy?"
            }
        }
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'Destroy' }
            }
            steps {
                sh "cd ${env.TERRAFORM_WORKSPACE} && terraform destroy -auto-approve"
            }
        }
        stage('Update Kubeconfig') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                withAWS(region: "${env.AWS_REGION}") {
                    sh '''
                        aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION} --kubeconfig ${KUBECONFIG}
                    '''
                }
            }
        }
        stage('Docker Login') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                echo 'Logging into Docker...'
                sh 'docker login -u 7720001490 -p Snatak@2024'
            }
        }
        stage('Deploy Application to EKS') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                sh """
                    export KUBECONFIG=${env.KUBECONFIG}
                    helm upgrade --install myapp ./helm-chart --set image.repository=${env.ECR_REPO},image.tag=${IMAGE_TAG}
                """
            }
        }
        stage('Kubernetes Deployment') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                echo 'Deploying to Kubernetes...'
                withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG')]) {
                    sh '''
                        #!/bin/bash
                        kubectl apply -f statefulsets.yaml
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
        stage('Verify Deployment') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl get nodes
                    kubectl get pods --all-namespaces
                '''
            }
        }
    }
    post {
        success {
            echo 'Pipeline Succeeded!'
        }
        failure {
            echo 'Pipeline Failed!'
        }
    }
}
