#!/usr/bin/env ruby

require 'net/http'

require 'rexml/document'
include REXML

use_proxy = true
proxy_srvr = "127.0.0.1"
proxy_port = "8080"
proxy_user = ""
proxy_pass = ""

twitter_user = "mubix"
twitter_pass = "password"


header = {
	'User-Agent' => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3 (.NET CLR 3.5.30729)",
	'X-Requested-With' => "XMLHttpRequest",
	'Cookie' => "__utma=" # Fill this part out with a captured cookie
}

data = "authenticity_token=" # Fill this part out with a captured auth token


doc = "temp"

if use_proxy == true
	Net::HTTP::Proxy(proxy_srvr, proxy_port, proxy_user, proxy_pass).start('twitter.com') {|http|
	    req = Net::HTTP::Get.new('/blocks/blocking/ids.xml')
	    req.basic_auth twitter_user, twitter_pass
	    response = http.request(req)
	    doc = Document.new response.body
	}
else
        Net::HTTP.start('twitter.com') {|http|
            req = Net::HTTP::Get.new('/blocks/blocking/ids.xml')
            req.basic_auth twitter_user, twitter_pass
            response = http.request(req)
            doc = Document.new response.body
	}
end



blocks = doc.elements.each('//id') { |f| 
	if use_proxy == true
	        Net::HTTP::Proxy(proxy_srvr, proxy_port, proxy_user, proxy_pass).start('twitter.com') {|http|
	            req2 = '/blocks/destroy/' + f.text
		    response2 = http.post(req2, data, header)
		    puts response2.code
	        }
	else
	        Net::HTTP.start('twitter.com') {|http|
	            req = Net::HTTP::Post.new('/blocks/destroy/' + f.text)
	            response = http.request(req, data)
                    puts response.code
	        }
	end

	puts "Unblocking: " + f.text 
}
