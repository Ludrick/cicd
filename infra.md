# Access and Credentials:

Autenticating to use SSO AWS CLI:
```
# to login in the personal account:
aws sso login --profile personalsso

# to use the personal as default for commands, so we dont need the --profile
$Env:AWS_PROFILE = "personalsso"
```

# Create resources:

## S3:

### Create s3 bucket via Power Shell:

```
aws s3api create-bucket `
  --bucket cicdproj-calls-env2 `
  --region us-east-1
  # us-east-1 does not use LocationConstraint (historical exception)
```

### Create folders, that is prefixes:
```
aws s3api put-object `
  --bucket cicdproj-calls-env2 `
  --key landing_zone/

aws s3api put-object `
  --bucket cicdproj-calls-env2 `
  --key processed/
```

## DynamoDB:
```
aws dynamodb create-table `
    --table-name cicdproj_calls_bronze_env2 `
    --attribute-definitions AttributeName=ip,AttributeType=S AttributeName=timestamp,AttributeType=N `
    --key-schema AttributeName=ip,KeyType=HASH AttributeName=timestamp,KeyType=RANGE `
    --billing-mode PAY_PER_REQUEST `
    --region us-east-1
```


## Lambda functions:

### Lambda Role: 
Needs to create the **lambda-exec-role-s3-dynamo** role. Example of permissions for the role:
 - AmazonDynamoDBFullAccess
 - AmazonS3FullAccess
 - AWSLambdaBasicExecutionRole

### Deploying with zip file:
Needs a requirements.txt with small libraries, since zip deployment has size limitation.
```
cd /path/to/cicd/data/bronze
mkdir libs
python -m pip install --upgrade -r requirements.txt -t ./libs



1) Vá até a pasta do bronze
cd "C:\Users\lucia\OneDrive\Documentos\+Data Engineer Learnings\CICD Project\repo\cicd\data\bronze"

2) Remover todos __pycache__ dentro de libs/
Get-ChildItem .\libs -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force

 Se tiver subpastas com __pycache__, o comando acima já remove.
# Faça o mesmo para o ../common, se existir:
Get-ChildItem "..\common" -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force

3) Compactar handler.py, libs e ..\common em "function.zip"
Compress-Archive -Path .\handler.py, .\libs, ..\common -DestinationPath function.zip -Force




aws lambda create-function `
  --function-name cicdproj_calls_bronze_env2 `
  --runtime python3.12 `
  --role arn:aws:iam::599224842127:role/lambda-exec-role-s3-dynamo `
  --handler handler.lambda_handler `
  --zip-file fileb://function.zip `
  --region us-east-1
```


## S3 Notification for triggering the Lambda:

Create notification.json file:
```
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "cicdproj-calls-env2-notification",
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:599224842127:function:cicdproj_calls_bronze_env2",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            { "Name": "prefix", "Value": "landing_zone/" },
            { "Name": "suffix", "Value": ".json" }
          ]
        }
      }
    }
  ]
}

```

run on PowerShell:
```
aws s3api put-bucket-notification-configuration `
    --bucket cicdproj-calls-env2 `
    --notification-configuration file://notification.json `
    --region us-east-1
```


# Set up Github Action CI/CD:
1. No seu repositório do GitHub, vá em Settings > Security > Secrets and variables > Actions > New repository secret.

2. Crie dois secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

