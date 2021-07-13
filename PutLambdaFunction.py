import boto3
import os
import json

from botocore.exceptions import ClientError

def publish_error_message(id, value):
    sns_arn = os.environ['snsARN']  # Getting the SNS Topic ARN passed in by the environment variables.
    snsclient = boto3.client('sns')
    response = {
            'statusCode': 200,
            'body': 'The Item already exists!',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
        }

    message = ""
    message += "\nLambda error  summary" + "\n\n"
    message += "##########################################################\n"
    message += "# The itam with the id:" + id + " and value:" + value + " already exists!" + "\n"
    message += "# Please try again with diffrent id." + "\n"
    message += "##########################################################\n"

    # Sending the notification...
    snsclient.publish(
        TargetArn=sns_arn,
        Subject=f'Execution error for Lambda - PutLambdaFunction',
        Message=message
    )
    return response


def lambda_handler(event, context):
    dynamodb_client = boto3.client('dynamodb')
    # Add a new item with an Id and value
    id = event['queryStringParameters']['myId']
    value = event['queryStringParameters']['myValue']

    try:
        response = {
            'statusCode': 200,
            'body': 'successfully created item!',
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
        }
        data = dynamodb_client.put_item(
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
        return response
    except ClientError as e:
        return publish_error_message(id, value)