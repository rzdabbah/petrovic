from os import environ


class AppConf:
    
    def __init__(self):
        self.conf_dict = dict()

        appconf = dict()
        self.conf_dict['pstg_host'] = (environ.get('pstg_host') if environ.get('pstg_host') else 'my-postgres-cluster.cluster-csjlydmlpmsf.us-west-2.rds.amazonaws.com')
        self.conf_dict['pstg_db'] = (environ.get('pstg_db') if environ.get('pstg_db') else 'postgres')
        self.conf_dict['pstg_user'] = (environ.get('pstg_user') if environ.get('pstg_user') else 'mandomauser')
        self.conf_dict['pstg_password'] = (environ.get('pstg_password') if environ.get('pstg_password') else 'mandomapassword')
        self.conf_dict['petrovic_bucket_name'] = (environ.get('petrovic_bucket_name') if environ.get('petrovic_bucket_name') else 'petrovic-samer')
        self.conf_dict['queue_url'] = (environ.get('queue_url') if environ.get('queue_url') else 'https://sqs.us-west-2.amazonaws.com/581385275748/petrovic_queue')
        self.conf_dict['aws_access_key'] = environ.get('AWS_ACCESS_KEY') 
        self.conf_dict['aws_secret_key'] = environ.get('AWS_SECRET_KEY') 
        self.conf_dict['aws_region_name'] = environ.get('AWS_REGION') if environ.get('AWS_REGION') else "us-west-2" 

                                            
        print(self.conf_dict)

    def get(self, property_name, default_value= None):
        return  self.conf_dict.get(property_name) if self.conf_dict.get(property_name) else default_value
    
    def set(self, property_name, value):
          self.conf_dict[property_name]  = value
    

