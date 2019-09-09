#!/usr/bin/env python
# -*- coding: utf-8 -*-

import web

urls = ("/dynamic", "hello")
app = web.application(urls, globals())

class hello:
	def GET(self):
		return 'Hello World from dynamic page!'

if __name__ == "__main__":
	web.wsgi.runwsgi = lambda func, addr=None: web.wsgi.runfcgi(func, addr)
	app.run()
