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