import json
import boto3

def get_volume_id(volume_arn):
    arn_parts = volume_arn.split(":")
    volume_name_with_id = arn_parts[-1].split("/")
    volume_id = volume_name_with_id[-1]
    return volume_id

def lambda_handler(event, context):
    print(event)
    volume_arn = event['resources'][0]
    volume_id = get_volume_id(volume_arn)
    aws_client = boto3.client('ec2')
    response = aws_client.modify_volume(
        VolumeId=volume_id,
        VolumeType='gp3'
    )
    print(response)
    # if response.TargetVolumeType == 'gp3':
    #     print("Volume successfully modified to gp3")
    # else:
    #     print("Something went wrong!")
    # return {
    #     'statusCode': 200,
    #     'body': json.dumps('Hello from Lambda!')
    # }
