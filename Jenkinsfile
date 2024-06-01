pipeline{
     agent any
	 tools {
	     terraform 'Terraform1.8'
	 }
	 stages{
	     stage('Git Checkout'){ 
		     steps{
			 git branch: 'main', credentialsId: 'git username and password', url: 'https://github.com/yrathore9911/Awsinfra.git'
			 }
		 }
	     stage('Terraform init'){ 
		     steps{
			 sh 'terraform init'
			 }
		 }
		 stage('Terraform plan'){ 
		     steps{
			 sh 'terraform plan'
			 }
		 }
		 stage('Terraform apply '){ 
		     steps{
			 sh 'terraform apply --auto-approve'
			 }
		 }
	 }
}
