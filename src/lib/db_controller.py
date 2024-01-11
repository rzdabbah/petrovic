import psycopg2

from lib.app_config import AppConf

class DbController():
    def __init__(self, app_conf:AppConf) -> None:
        
        self.conn = psycopg2.connect(
            host= app_conf.get('pstg_host'),
            database= app_conf.get('pstg_db'),
            user= app_conf.get('pstg_user'),
            password= app_conf.get('pstg_password'))
        print("DB coonection done !")

    def getConnection(self):
        return self.conn
    
    def checkStatus(self, bucket_name, object_id ):
        cursor = self.conn.cursor()
        query = " select status from status where bucketname = '%s' and objectid = '%s' ; " % (bucket_name,object_id)
        res = cursor.execute(query)
        return res if not res else res.fetchone()
    
    def get_next_file(self):
        cursor = self.conn.cursor()
        query = " select status.bucketname, status.objectId from status"
        cursor.execute(query)
        res = cursor.fetchone()
        return res 
    
    def add_object_status(self, bucket_name, object_id ):
        print(object_id)
        cursor = self.conn.cursor()
        query = " INSERT INTO  status(bucketname, objectId, status) VALUES ('%s', '%s',0)  ;" % (bucket_name,object_id)
        try:
            cursor.execute(query)
            self.conn.commit()
        except Exception as ex:
            print (ex)
            pass

    def create_status_table_if_not_exits(self ):

        cursor = self.conn.cursor()
        query = "CREATE TABLE IF NOT EXISTS status (bucketName VARCHAR ( 50 ) NOT NULL,objectId VARCHAR ( 50 ) NOT NULL,status INT ,PRIMARY KEY (bucketName, objectId))  ;"
        try:
            cursor.execute(query)
            self.conn.commit()
            print ("Status table created")
        except Exception as ex:
            print (ex)
            pass

