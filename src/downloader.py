import boto3
import asyncio
from yarl import URL
from lib.app_config import AppConf
from  lib.db_controller import DbController
from  lib.queue_cotroller import QueueController
from lib.aws_controller import awsClientManger
import gzip
from io import StringIO
from smart_open import open

app_conf = AppConf()
awsController = awsClientManger(app_conf)


def process_file (bucket_name,object_id):
    source_uri = "s3://%s/%s" % (bucket_name,object_id)
    print("Processign: %s"%source_uri)
    s3_client = awsController.get_s3_client()
    fileobj = s3_client.get_object(
        Bucket=bucket_name,
        Key=object_id
    )
    queue_controller = QueueController(app_conf)
 
    for json_line in open(source_uri, transport_params={"client": s3_client}):
        queue_controller.send_message(json_line)

def add_all_bucket_keys_to_db ():

    postgress = DbController(app_conf)
    postgress.create_status_table_if_not_exits()
    s3_objs = awsController.get_s3_client().list_objects(Bucket=app_conf.get('petrovic_bucket_name'), Prefix ="petrovic_")['Contents']
    for obj in s3_objs:  postgress.add_object_status(app_conf.get('petrovic_bucket_name'),obj['Key'])


def run():
    add_all_bucket_keys_to_db()
    postgress = DbController(app_conf)
    res =  postgress.get_next_file()
    bucket_name = res[0]
    objectId = res[1]
    process_file(bucket_name,objectId)



# start here

run()
#loop = asyncio.get_event_loop()
#tasks = loop.run_until_complete([])
#loop.run_until_complete(asyncio.gather(*tasks))

#loop.run_until_complete()