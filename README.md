Paparazzo.js
-

_A stalker of [IP cameras](http://en.wikipedia.org/wiki/IP_camera)_

**What is this?**

A high performance web proxy for serving [MJPG](http://en.wikipedia.org/wiki/Motion_JPEG) streams to the masses.

IPCamera (1) <-> (1) Paparazzo.js (1) <-> (N) Users

Background
-

**IP cameras can't handle web traffic**

IP cameras are slow devices that can't handle a regular amount of web traffic. So if you plan to go public with an IP camera you have the following options:

1. **The naive approach** - Embed the camera service directly in your site, e.g. http://201.166.63.44/axis-cgi/jpg/image.cgi?resolution=CIF.
2. **Ye olde approach** - Serve images as static files in your server. I've found that several sites use this approach through messy PHP background jobs that update this files at slow intervals, generating excessive (and unnecessary) disk accesses.
3. **Plug n' pray approach** - Embed a flash or Java-based player, such as the  [Cambozola](http://www.charliemouse.com/code/cambozola/) player. This requires plugins.
4. **MJPG proxy** - Serve the MJPG stream directly if you are targeting only grade A browsers, (sorry IE).
5. **Paparazzo.js: A web service of dynamic images** - Build a MJPG proxy server which parses the stream, updates images in memory, and delivers new images on demand. I've found that this approach is scalable, elegant, blazing fast and doesn't require disk access.

Usage
-

**Server side**

	# Initialize
	
	# Same parameters as http.get http://nodejs.org/docs/v0.6.0/api/http.html#http.get
	paparazzo = new Paparazzo 
	    host: 'camera.dyndns.org'
	    port: 1881
	    path: '/mjpg/video.mjpg'

	paparazzo.on "update", (image) => 
	    console.log "Downloaded #{image.length} bytes"

	paparazzo.on 'error', (error) => 
	    console.log "Error: #{error.message}"

	paparazzo.start()
		
	# Serve image
	# Take a look to server.coffee

**Client side**

You can simulate MJPG streaming by requesting new images on a specific interval. Appending a random parameter avoids caching.

	// JavaScript example using jQuery

	// Active camera will refresh every 2 seconds
	var TIMEOUT = 2000;
	var refreshInterval = setInterval(function() {
		var random = Math.floor(Math.random() * Math.pow(2, 31));
		$('img#camera').attr('src', 'http://localhost:3000/camera?i=' + Math.random());
	}, TIMEOUT);	


	<!-- In your HTML output -->
	<img src='' id='camera' />

Upcoming features
-  
* Websockets implementation to get more FPS

Tested with
-
* Axis
* Vivotek

TODO
-  
* Testing!
* Find more public cameras to test

License  
-  

(The MIT License)

Copyright (c) 2012 Rodolfo Wilhelmy <[rwilhelmy@gmail.com](mailto:rwilhelmy@gmail.com)>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
