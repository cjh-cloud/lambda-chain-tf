import boto3
import os
from aws_xray_sdk.core import patcher, xray_recorder

# Patch the requests module to enable automatic instrumentation
patcher.patch(("boto3",))

# Configure the X-Ray recorder to generate segments with our service name
xray_recorder.configure(service="Lambda Service Dev")

QUEUE_NAME = os.getenv("queue_name")


def lambda_handler(event, context):
    result = "Hello World"

    # Get the service resource
    sqs = boto3.resource("sqs")

    print(QUEUE_NAME)

    # Get the queue. This returns an SQS.Queue instance
    queue = sqs.get_queue_by_name(QueueName=QUEUE_NAME)

    # You can now access identifiers and attributes
    print(queue.url)
    print(queue.attributes.get("DelaySeconds"))

    # Create a new message
    response = queue.send_message(MessageBody=result, MessageGroupId="Test")

    return {"statusCode": 200, "body": response}
