#!/usr/bin/env python
# -*- coding: utf-8 -*-

import web
import mysql.connector
import boto3


urls = ("/dynamic", "hello")
app = web.application(urls, globals())

class hello:
        def GET(self):
                client = boto3.client('rds',region_name='us-east-1')
                token = client.generate_db_auth_token('test-database.c1eo8ftt0y1z.us-east-1.rds.amazonaws.com',3306,'ec2')

                mydb = mysql.connector.connect(
                    host = "test-database.c1eo8ftt0y1z.us-east-1.rds.amazonaws.com",
                    password = token,
                    ssl_ca = 'rds-combined-ca-bundle.pem',
               #    auth_plugin = 'mysql_clear_password',
                    user = 'ec2',
                    database = 'testdb'
                )

                cursor = mydb.cursor(buffered=True)

                index_query = "SELECT count FROM indexes"
                cursor.execute(index_query)
                new_index = int(cursor.rowcount) + 1
                mydb.commit()
                add_index_query = "INSERT INTO indexes (count) VALUES (%s)"
                new = (new_index,)
                cursor.execute(add_index_query, new)
                mydb.commit()
                mydb.close()
                return """<html>
<header><title>Dynamic page</title></header>
<body>
<h1>Vists number: {}</h1>
<p>Hello World from dynamic page</p>
</body>
</html>""".format(new_index)

if __name__ == "__main__":
        web.wsgi.runwsgi = lambda func, addr=None: web.wsgi.runfcgi(func, addr)
        app.run()

