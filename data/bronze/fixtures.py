event = {
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-east-1",
      "eventTime": "2025-01-01T12:00:00.000Z",
      "eventName": "ObjectCreated:Put",
      "userIdentity": {
        "principalId": "AWS:EXAMPLE123"
      },
      "requestParameters": {
        "sourceIPAddress": "127.0.0.1"
      },
      "responseElements": {
        "x-amz-request-id": "EXAMPLE123456789",
        "x-amz-id-2": "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH"
      },
      "s3": {
        "s3SchemaVersion": "1.0",
        "configurationId": "cicdproj-calls-env2-notification",
        "bucket": {
          "name": "cicdproj-calls-env2",
          "ownerIdentity": {
            "principalId": "EXAMPLE"
          },
          "arn": "arn:aws:s3:::cicdproj-calls-env2"
        },
        "object": {
          "key": "landing_zone/calls01.json",
          "size": 1024,
          "eTag": "0123456789abcdef0123456789abcdef",
          "sequencer": "0A1B2C3D4E5F678901"
        }
      }
    }
  ]
}





# [
#   {
#     "ip": "ip101",
#     "uf": "MG",
#     "duration": 25
#   },
#   {
#     "ip": "ip102",
#     "uf": "SP",
#     "duration": 13
#   },
#   {
#     "ip": "ip103",
#     "uf": "SC",
#     "duration": 48
#   }
# ]
