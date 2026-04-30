pipeline {

    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action')
        choice(name: 'ENV', choices: ['dev'], description: 'Environment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Skip manual approval')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_VAR_file = "${params.ENV}.tfvars"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm   // cleaner than manual git
            }
        }

        stage('Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -reconfigure'
                }
            }
        }

         // 🔥 ADD THIS STAGE HERE
        stage('Reset') {
            when {
                expression { params.resetInfra == true }
            }
            steps {
                dir('terraform') {
                    sh '''
                    terraform init -reconfigure

                    terraform apply \
                      -replace=random_password.db_password \
                      -replace=aws_db_instance.rds \
                      -var-file=envs/dev.tfvars \
                      -auto-approve
                    '''
                }
            }
        }

        stage('Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Plan') {
            steps {
                dir('terraform') {

                    script {
                        if (params.ACTION == 'apply') {
                            sh """
                            terraform plan \
                              -var-file=envs/${params.ENV}.tfvars \
                              -out=tfplan
                            """
                        } else {
                            sh """
                            terraform plan -destroy \
                              -var-file=envs/${params.ENV}.tfvars \
                              -out=tfplan
                            """
                        }
                    }

                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Approval') {
            when {
                allOf {
                    expression { params.autoApprove == false }
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'

                    timeout(time: 5, unit: 'MINUTES') {
                        input(
                            message: "Approve Terraform ${params.ACTION}?",
                            ok: "Proceed",
                            parameters: [
                                text(
                                    name: 'Plan Preview',
                                    defaultValue: plan.take(5000),
                                    description: 'Review plan before execution'
                                )
                            ]
                        )
                    }
                }
            }
        }

        stage('Apply / Destroy') {
            steps {
                dir('terraform') {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -input=false tfplan'
                        } else {
                            sh 'terraform apply -destroy -input=false tfplan'
                        }
                    }
                }
            }
        }
    }
}
