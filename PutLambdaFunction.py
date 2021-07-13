import boto3
import os

from botocore.exceptions import ClientError

def publish_error_message(id, value):
    sns_arn = os.environ['snsARN']  # Getting the SNS Topic ARN passed in by the environment variables.
    snsclient = boto3.client('sns')

    message = ""
    message += "\nLambda error  summary" + "\n\n"
    message += "##########################################################\n"
    message += "# The itamwith the id:" + id + " and value:" + value + " already exists!" + "\n"
    message += "# Please try again with diffrent id." + "\n"
    message += "##########################################################\n"

    # Sending the notification...
    snsclient.publish(
        TargetArn=sns_arn,
        Subject=f'Execution error for Lambda - PutLambdaFunction',
        Message=message
    )


def lambda_handler(event, context):
    dynamodb_client = boto3.client('dynamodb')
    # Add a new item with an Id and value
    id = event['myId']
    value = event['myValue']

    try:
        response = dynamodb_client.put_item(
            TableName='MyDb',
            Item={
                'myId': {
                  'S': id
                },
                'myValue': {
                  'S': value
                }
            },
            ConditionExpression='attribute_not_exists(myId)'
          ) # Someone tried to insert an item with an existing id (which will fail).
    except ClientError as e:
        publish_error_message(id, value)
    else:
        return response