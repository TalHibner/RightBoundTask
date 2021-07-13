import boto3
import os

def publish_error_message(id):
    sns_arn = os.environ['snsARN']  # Getting the SNS Topic ARN passed in by the environment variables.
    snsclient = boto3.client('sns')

    message = ""
    message += "\nLambda error  summary" + "\n\n"
    message += "##########################################################\n"
    message += "#The item with the " + id + " doesn't exist!" + "\n"
    message += "# Please try again with diffrent item." + "\n"
    message += "##########################################################\n"

    # Sending the notification...
    snsclient.publish(
        TargetArn=sns_arn,
        Subject=f'Execution error for Lambda - GetLambdaFunction',
        Message=message
    )


def lambda_handler(event, context):
    dynamodb_client = boto3.client('dynamodb')
    # Get an item according to Id (myId)
    id = event['myId']

    response = dynamodb_client.query(
        TableName='MyDb',
        KeyConditionExpression='myId = :myId',
        ExpressionAttributeValues={
            ':myId': {
                'S': id
            }
        }
    )
    # Someone asked for an item  that doesn't exist
    if response["Count"] == 0:
        publish_error_message(id)

    return response
