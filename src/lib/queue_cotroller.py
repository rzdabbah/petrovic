import boto3
from lib.aws_controller import awsClientManger
class QueueController():
    def __init__(self, app_conf) -> None:
        # Create SQS client
        self.sqs = awsClientManger(app_conf).get_sqs_client()
        self.queue_url = app_conf.get('queue_url')
        print(self.queue_url)
    
    def send_message(self, msg:str):
        # Send message to SQS queue
        try:
            response = self.sqs.send_message(
                QueueUrl=self.queue_url,
                DelaySeconds=10,
                MessageAttributes={
                },
                MessageBody=msg
            )
            print(response['MessageId'])
        except  Exception as ex:
            print (ex)
            print (msg)

