import boto3
from lib.app_config import AppConf



class awsClientManger():

    def __init__(self, app_conf:AppConf) -> None:
           self.app_conf = app_conf
    def get_s3_client(self):
            s3_client = boto3.client('s3',
                            region_name= self.app_conf.get('aws_region_name'),    
                            aws_access_key_id= self.app_conf.get('aws_access_key'),
                            aws_secret_access_key=self.app_conf.get('aws_secret_key'))
            return s3_client
    def get_sqs_client(self):
            sqs_client = boto3.client('sqs',
                                      region_name= self.app_conf.get('aws_region_name'),    
                    aws_access_key_id= self.app_conf.get('aws_access_key'),
                            aws_secret_access_key=self.app_conf.get('aws_secret_key'))
            return sqs_client