import sys
import os

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
LIBS_DIR = os.path.join(CURRENT_DIR, "libs")

# Prepend the libs directory to sys.path so Python can find installed packages
sys.path.insert(0, LIBS_DIR)

import json
import boto3
from datetime import datetime, timezone
from data.common.config import env

s3_client = boto3.client("s3", region_name="us-east-1")
dynamodb = boto3.resource("dynamodb", region_name="us-east-1")


TABLE_NAME = f"cicdproj_calls_bronze_{env}"

def lambda_handler(event, context):
    """
    Lambda handler that is triggered when a new JSON file is placed in the S3
    bucket. It reads the file content from S3 and stores each record in the
    'cicdproj_calls_bronze_envx' DynamoDB table.

    Partition Key: ip (String)
    Sort Key: timestamp (Number)
    """

    record = event["Records"][0]
    bucket_name = record["s3"]["bucket"]["name"]
    object_key = record["s3"]["object"]["key"]

    # Download the object from S3
    response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    file_content = response["Body"].read().decode("utf-8")

    # Parse the JSON
    try:
        calls_data = json.loads(file_content)
    except json.JSONDecodeError:
        print("Error parsing JSON file.")
        return {"statusCode": 400, "body": json.dumps({"message": "Invalid JSON format"})}

    # Reference the DynamoDB table
    table = dynamodb.Table(TABLE_NAME)

    for record_item in calls_data:
        ip = record_item.get("ip")
        uf = record_item.get("uf")
        duration = record_item.get("duration")

        # Use the current UTC epoch (integer) as the sort key
        current_timestamp = int(datetime.now(timezone.utc).timestamp())

        item = {
            "ip": ip,
            "timestamp": current_timestamp,
            "uf": uf,
            "duration": duration
        }

        try:
            table.put_item(Item=item)
            print(f"Inserted item: {item}")
        except Exception as e:
            print(f"Error inserting item {item}: {str(e)}")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Processing complete"})
    }

if __name__ == "__main__":
    from data.bronze.fixtures import event as local_event
    print("Running locally with fixture event...")
    response = lambda_handler(local_event, None)
    print(f"Lambda response: {response}")
