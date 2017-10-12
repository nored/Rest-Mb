#!/usr/bin/env ruby

# rest-mb.rb - Lightweight restfull webserver for serving mandelbrot
# images
# Copyright (C) 2017 Klaus Schwarz <schwarz[aet]posteo[dot]de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

require 'socket'
require 'uri'
require 'securerandom'

def shut_down
  puts "\nShutting down gracefully..."
  sleep 1
end

puts "I have PID #{Process.pid}"

# Trap ^C 
Signal.trap("INT") { 
  shut_down 
  exit
}

# Trap `Kill `
Signal.trap("TERM") {
  shut_down
  exit
}

def open_file(filename)
	begin
      displayfile = File.open(filename, 'r')
      content = displayfile.read()
      @session.print content
   rescue Errno::ENOENT
      @session.print "404 Not Found"
   end
end

def index
   @session.print(%Q+<!DOCTYPE html>
<html>
  <head>
    <title>Mandelbrot REST</title>
  </head>
  <body>
    <h1>Awesome Mandelbrot REST API</h1>
    <p>Don't know how it works? Use a call like this:</p>
    <p>"/Mandelbrot/getMandelbrot?w=800&h=600&it=1000"</p>
    <a href="/Mandelbrot/getMandelbrot?w=800&h=600&it=1000">or try this link...</a>
  </body>
</html>+)
end

reg = /mandel-\w*.png/
webserver = TCPServer.new('', 80)
while (@session = webserver.accept)
   @session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
   request = @session.gets
   trimmedrequest = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '')
   uri = URI(trimmedrequest.chomp)
   if uri.path == "" || uri.path == "index.html" || uri.path == "Mandelbrot" || uri.path == "Mandelbrot/"
    index
   elsif uri.path =~ reg
      open_file(uri.path.split("/")[1])    
   elsif uri.path == "Mandelbrot/getMandelbrot"
      queryParams = true
      if !URI.parse(uri.to_s).query.nil?
      	params = URI::decode_www_form(uri.query).to_h
         if !params["w"].class == Integer || !params.key?("w")
            queryParams = false
         end
         if !params["h"].class == Integer || !params.key?("h")
            queryParams = false
         end
         if !params["it"].class == Integer || !params.key?("it")
            queryParams = false
         end
         if queryParams
            random_string = SecureRandom.hex
   	     `python mandelbrot.py #{params["w"]} #{params["h"]} #{params["it"]} #{random_string}`
            @session.print(%Q+<img src="mandel-#{random_string}.png">+)
         else
            @session.print "404 Not Found"
         end
      else
         @session.print "404 Not Found"
      end
   else
   	@session.print "404 Not Found" 	
   end
   @session.close
end


