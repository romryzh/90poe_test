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
    user = 'ec2',
    password = token
)

urls = ("/dynamic", "hello")
app = web.application(urls, globals())

class hello:
	def GET(self):
		return """<html>
<header><title>Dynamic page</title></header>
<body>
Hello World from dynamic page!
</body>
</html>"""

if __name__ == "__main__":
	web.wsgi.runwsgi = lambda func, addr=None: web.wsgi.runfcgi(func, addr)
	app.run()
