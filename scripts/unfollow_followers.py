#!/usr/bin/python

# This script will force anyone who is following you
# but you aren't following them to unfollow you. Use
# the other script first if you want to 0 out both.

import twitter
import urllib2

headers = {
'User-Agent' : "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3 (.NET CLR 3.5.30729)",
'Accept' : "application/json, text/javascript, */*",
'Accept-Language' : "en-us,en;q=0.5",
'Accept-Encoding' : "gzip,deflate",
'Accept-Charset' : "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
'Keep-Alive' : "300",
'Proxy-Connection' : "keep-alive",
'Content-Type' : "application/x-www-form-urlencoded; charset=UTF-8",
'X-Requested-With' : "XMLHttpRequest",
'Referer' : "http://twitter.com/followers",
'Cookie'  : "__utma=", # Fill this part out with a captured cookie
'Pragma' : "no-cache",
'Cache-Control' : "no-cache",
'Content-Length' : "70"
}

data = "authenticity_token=" # Fill this part out with a captured auth token



api = twitter.Api(username='changeme', password='password')
for b in range(1,100):
	users = api.GetFollowers(page=b)
	for i in users:
		request = "http://twitter.com/friendships/remove/" + str(i.id)
		req = urllib2.Request(request,data,headers)
		post = urllib2.urlopen(req)
		print post


		
