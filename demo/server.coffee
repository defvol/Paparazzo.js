# Using the Paparazzo.js module

Paparazzo = require '../src/paparazzo'
http = require 'http'
url = require 'url'

# For a list of public cameras to test check:
# https://github.com/rodowi/Paparazzo.js/wiki/List-of-public-cameras

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

