import boto3
from aws_xray_sdk.core import patcher, xray_recorder

# Patch the requests module to enable automatic instrumentation
patcher.patch(("boto3",))

# Configure the X-Ray recorder to generate segments with our service name
xray_recorder.configure(service="Lambda Service Dev")


def lambda_handler(event, context):
    print(event)

    result = "Hello World"
    return {"statusCode": 200, "body": result}
