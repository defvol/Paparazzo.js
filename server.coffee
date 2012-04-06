# Using the Paparazzo.js module

Paparazzo = require './paparazzo'
http = require 'http'
url = require 'url'

# Some hosts I found googling:

# Success
# http://85.105.120.239:1881/mjpg/video.mjpg
# http://94.86.192.168/mjpg/video.mjpg
# http://hg55.no-ip.org/mjpg/video.mjpg

# Server closed connection
# http://ip6d6d7343.static.cbizz.nl/BufferingImage?Type=2&ImageAdr=131072

# Can't find image boundary
# http://61.119.240.67/nphMotionJpeg?Resolution=320x240&Quality=Standard

paparazzo = new Paparazzo 
    host: '85.105.120.239'
    port: 1881
    path: '/mjpg/video.mjpg'

updatedImage = ''

paparazzo.on "update", (image) => 
    updatedImage = image
    console.log "Downloaded #{image.length} bytes"

paparazzo.on 'error', (error) => 
    console.log "Error: #{error.message}"

paparazzo.start()

http.createServer (req, res) -> 
    data = ''
    path = url.parse(req.url).pathname
        
    if path == '/camera' and updatedImage?
        data = updatedImage
        console.log "Will serve image of #{data.length} bytes"

    res.writeHead 200, 
        'Content-Type': 'image/jpeg'
        'Content-Length': data.length

    res.write data, 'binary'
    res.end()
.listen(3000)

