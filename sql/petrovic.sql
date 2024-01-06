CREATE TABLE IF NOT EXISTS status (
   bucketName VARCHAR ( 50 ) NOT NULL,
   objectId VARCHAR ( 50 ) NOT NULL,
   status INT ,
   PRIMARY KEY (bucketName, objectId)
)



INSERT INTO status(bucketname, objectId, status)
VALUES ('petrovic-samer', 'petrovic_27500000.gz',0)


select status from status where bucketname = %s and objectid = %s
