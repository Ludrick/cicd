# **CICD Learning Project**

## **Project Overview**

This repository is a personal project to dive into and level up my skills with AWS resource management, IAM permissions, Docker, GitHub Actions, CICD pipelines, and Terraform for Infrastructure as Code (IaC)..

The project will simulate a system for storing and retrieving data about games, using AWS services such as ECR, S3, Lambda, and DynamoDB. Below is an outline of the project's components and goals.

---

## **Learning Objectives**
- Manage IAM roles and policies effectively to provide secure access to AWS resources.
- Learn to use uv to manage Python libraries in Lambda deployments.
- Explore different methods of deploying Lambda functions (ZIP and Docker).
- Build and maintain robust GitHub Actions workflows for CICD.
- Use Terraform to define, deploy, and manage infrastructure as code.
- Gain experience with serverless architectures and event-driven systems.

---

## **Architecture**
1. **S3 Bucket:**
   - A folder within a S3 bucket will serve as the upload destination for JSON files containing information about games.
   - Each JSON file will be automatically processed upon upload by a Lambda function.

2. **Lambda Functions:**
   - **Lambda 1:** Triggered by the S3 bucket to process the uploaded JSON files. It will parse the files and store the data as new rows in a DynamoDB table. This function will be deployed as a ZIP package.
   - **Lambda 2:** Exposed via an HTTP endpoint to retrieve game information from the DynamoDB table. This function will be containerized using Docker and AWS ECR, and deployed to AWS Lambda.

3. **DynamoDB Table:**
   - Acts as the central data store for game information.

4. **CICD Pipelines:**
   - Automated pipelines in GitHub will manage the entire build and deployment process for the Lambda functions.

5. **Terraform:**
   - All infrastructure resources (S3 bucket, Lambda functions, DynamoDB table, IAM roles, etc.) will be defined and deployed using Terraform.

---

## **Future Plans**
This project will be developed incrementally:
1. Create the basic architecture using AWS Management Console for initial testing.
2. Deploy Lambda 1 as a ZIP package and test its integration with S3 and DynamoDB.
3. Deploy Lambda 2 as a Docker container and test its functionality via HTTP requests.
4. Implement GitHub Actions pipelines for automated deployment.
5. Transition to Terraform for infrastructure management.

---

