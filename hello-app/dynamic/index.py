#!/usr/bin/env python
# -*- coding: utf-8 -*-

import web
import mysql.connector
import boto3

client = boto3.client('rds',region_name='us-east-1')
token = client.generate_db_auth_token('test-database.c1eo8ftt0y1z.us-east-1.rds.amazonaws.com',3306,'test')

mydb = mysql.connector.connect(
    host = "test-database.c1eo8ftt0y1z.us-east-1.rds.amazonaws.com",
    user = 'test',
    password = token,
    ssl_ca = 'rds-combined-ca-bundle.pem',
    auth_plugin = 'mysql_clear_password'
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
