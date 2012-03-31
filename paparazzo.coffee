# Standalone MJPG proxy
#
# Usage:
# p = new Paparazzo 
#     host: ''
#   , (err) ->
#     console.log err.message
# p.start
#
# TODO:
# - EventEmitter
#

http = require 'http'

class Paparazzo
    
    @image = ''
    imageExpectedLength = -1

    constructor: (options, callback) -> 
        
        callback({ message: 'Host is not defined!' }) if not options.host?
        options.port or= 80
        options.path or= '/'
        options.headers or= {}
        @options = options
        
    start: (callback) -> 
        
        request = http.get @options, (response) -> 
        
            if response.statusCode != 200 
                callback({ message: 'Server did not respond with HTTP 200 (OK).' })
                return
      
            contentType = response.headers['content-type']
            contentTypeMatch = contentType.match(/multipart\/x-mixed-replace;boundary=(.+)/)
            boundaryString = contentTypeMatch[1] if contentTypeMatch.length > 1
      
            if not boundaryString?
                callback({ message: 'Could not find a boundary string. Server is not serving MJPGs.' })
                return
        
            response.setEncoding 'binary'
      
            data = ''
      
            response.on 'data', (chunk) -> 
        
                # MJPG image boundary typically looks like this: 
                # --myboundary
                # Content-Type: image/jpeg
                # Content-Length: 64199
                # \r\n
        
                boundary = chunk.indexOf(boundaryString)
                if boundary != -1
                    # Append remaining data
                    data += chunk.substring 0, boundary
          
                    if imageExpectedLength == -1
                        # First run
                        @image = data
                        console.log "Downloaded #{@image.length} bytes"
                    else if imageExpectedLength != data.length
                        # Corrupted image
                        console.log "Corrupted image, expected #{imageExpectedLength} bytes and received #{data.length}"
                    else
                        # Image OK
                        @image = data
                        console.log "Downloaded #{@image.length} bytes"
            
                    data = ''
                    
                    remaining = chunk.substring boundary
                    matches = remaining.match /Content-Length:\s(\d+)\s+/
                    if matches? and matches.length > 1
                        # Grab length of new image and save first chunk
                        newImageBeginning = remaining.indexOf(matches[0]) + matches[0].length
                        imageExpectedLength = matches[1]
                        data += remaining.substring newImageBeginning
                    else
                        # Could not find Content-Length
                else
                    # Keep eating
                    data += chunk
        
            response.on 'end', () ->
                # Server closed connection 
        
        request.on 'error', (error) -> 
            # Failed to connect
            console.log "#{error.message}"
    
    stop: (callback) ->
        # TODO

module.exports.init = (options, callback) ->
    new Paparazzo options, callback

module.exports._class = Paparazzo