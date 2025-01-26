# **CICD Learning Project**

## **Project Overview**

This repository is a personal project to dive into and level up my skills with AWS resource management, IAM permissions, Docker, GitHub Actions, CICD pipelines, pytest, Cloudwatch and Terraform.

The project will simulate the logging of client calls to a server using AWS services such as ECR, S3, Lambda, DynamoDB, and CloudWatch. Below is an outline of the project's components and goals.

---

## **Learning Objectives**
- Manage IAM roles and policies effectively to provide secure access to AWS resources.
- Learn to use uv to manage Python libraries in Lambda deployments.
- Explore different methods of deploying Lambda functions (ZIP and Docker).
- Build and maintain robust GitHub Actions workflows for CICD.
- Use Terraform to define, deploy, and manage infrastructure as code.
- Gain experience with serverless architectures and event-driven systems.
- Build API server with Flask.
- Pytest
- CloudWatch

---

## **Architecture**

1 .**Enviroments:** All AWS resources should be deployed on the us-east-1 regions and have the enviroment as suffix:
   - env1: Deployed using AWS UI.
   - env2: Deployed locally using AWS CLI.
   - env3: Deployed with gitgub actions using AWS CLI.
   - env4: Deployed locally using Terraform.
   - env5: Deployed with gitgub action using Terraform.
   
1. **S3 Bucket:**
   - In the `cicdproj-calls-envx` S3 bucket, the `landing_zone` folder serves as the landing zone for JSON files containing information about the client call.
   - Each JSON file will be automatically processed and moved to the `processed` folder upon upload by a Lambda function.

2. **Lambda Functions and DynamoDB tables:**
   - **cicdproj_calls_bronze_envx Lambda:** Deployed as ZIP package and triggered by S3, it will parse the JSON files and save them as raw data in the `cicdproj_calls_bronze_envx` DynamoDB table.
   - **cicdproj_calls_silver_envx Lambda:** Deployed as Docker/ECR and triggered by the `cicdproj_calls_bronze_envx`, it will clean, enrich and save the data in the `cicdproj_calls_silver_envx` DynamoDB table.
   - **cicdproj_calls_gold_envx Lambda:** Deployed as Docker/ECR and exposed via an HTTP endpoint to retrieve call information from the `cicdproj_calls_silver_envx` DynamoDB table.

3. **CICD Pipelines:**
   - Automated pipelines in GitHub will manage the entire build and deployment process for the S3, DynamoDB and Lambda functions.

5. **Terraform:**
   - All infrastructure resources (S3 bucket, Lambda functions, DynamoDB table, etc.) will be defined and deployed using Terraform.

---

## **Plan:**
This project will be developed incrementally:
1. Create the basic architecture using AWS Management Console for initial testing.
2. Deploy Lambda 1 as ZIP package and test its integration with S3 and DynamoDB.
2. Deploy Lambda 2 as Docker image and test its integration with DynamoDB.
3. Deploy Lambda 3 as Docker image and test its functionality via HTTP requests.
4. Implement GitHub Actions pipelines for automated deployment.
5. Transition to Terraform for infrastructure management.

---

