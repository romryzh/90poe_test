#!/usr/bin/env python
# -*- coding: utf-8 -*-

import web
import mysql.connector
import boto3

client = boto3.client('rds',region_name='us-east-1')
token = client.generate_db_auth_token('test-database.c1eo8ftt0y1z.us-east-1.rds.amazonaws.com',3306,'ec2')

print token

mydb = mysql.connector.connect(
    host = "test-database.c1eo8ftt0y1z.us-east-1.rds.amazonaws.com",
    password = token,
    ssl_ca = 'rds-combined-ca-bundle.pem',
#    auth_plugin = 'mysql_clear_password',
    user = 'ec2'
)

cursor = mydb.cursor()

urls = ("/dynamic", "hello")
app = web.application(urls, globals())

class hello:
	def GET(self):
                index_query = ("SECLECT count FROM inexes")
                cursor.execute(index_query)
                index = cursor.count
                new_index= inex + 1
                add_index_query = ("INSERT INTO indexes (count) VALUES (%s)", new_index)
                cursor.execute(add_index_query)
                cursor.commit()
		return("""<html>
<header><title>Dynamic page</title></header>
<body>
Vists number: %s
Hello World from dynamic page!
</body>
</html>""", new_index)

if __name__ == "__main__":
	web.wsgi.runwsgi = lambda func, addr=None: web.wsgi.runfcgi(func, addr)
	app.run()
