#
# Paparazzo.js: A MJPG proxy for the masses
#
#   paparazzo = new Paparazzo(options)
#
#   paparazzo.on "update", (image) => 
#     console.log "Downloaded #{image.length} bytes"
#
#   paparazzo.start()
#

http = require 'http'
EventEmitter = require('events').EventEmitter

class Paparazzo extends EventEmitter

  @image = ''
  imageExpectedLength = -1

  constructor: (options) ->

    if not options.host?
      emitter.emit 'error',
        message: 'Host is not defined!'
    options.port or= 80
    options.path or= '/'
    options.headers or= {}
    @options = options
    @memory = options.memory or 8388608 # 8MB

  start: ->

    # To use EventEmitter in the callback, we must save our instance 'this'
    emitter = @

    request = http.get @options, (response) ->

      if response.statusCode != 200
        emitter.emit 'error',
          message: 'Server did not respond with HTTP 200 (OK).'
        return

      emitter.boundary = emitter.boundaryStringFromContentType response.headers['content-type']
      @data = ''

      response.setEncoding 'binary'
      response.on 'data', emitter.handleServerResponse
      response.on 'end', () ->
        emitter.emit 'error',
          message: "Server closed connection!"

    request.on 'error', (error) ->
      # Failed to connect
      emitter.emit 'error',
        message: error.message

  ###
  #
  # Find out the boundary string that delimits images.
  # If a boundary string is not found, it fallbacks to a default boundary.
  #
  ###
  boundaryStringFromContentType: (type) ->
    # M-JPEG content type looks like multipart/x-mixed-replace;boundary=<boundary-name>
    match = type.match(/multipart\/x-mixed-replace;\s*boundary=(.+)/)
    boundary = match[1] if match?.length > 1
    if not boundary?
      boundary = '--myboundary'
      @emit 'error',
        message: "Couldn't find a boundary string. Falling back to --myboundary."
    boundary

  ###
  #
  # Handles chunks of data sent by the server and restore images.
  #
  # A MJPG image boundary typically looks like this:
  # --myboundary
  # Content-Type: image/jpeg
  # Content-Length: 64199
  # \r\n
  #
  ###
  handleServerResponse: (chunk) =>
    boundary_index = chunk.indexOf(@boundary)

    # If a boundary is found, generate a new image from the data accumulated up to the boundary.
    # Otherwise keep eating. We will probably find a boundary in the next chunk.
    if boundary_index != -1
      # Append remaining data
      @data += chunk.substring 0, boundary_index
      # Now we got a new image
      @image = @data
      @emit 'update', @image

      # Start over
      @data = ''
      # Grab the remaining bytes of chunk
      remaining = chunk.substring boundary_index
      # Try to find the type of the next image
      typeMatches = remaining.match /Content-Type:\s+image\/jpeg\s+/
      # Try to find the length of the next image
      matches = remaining.match /Content-Length:\s+(\d+)\s+/

      if matches? and matches.length > 1
        # Grab length of new image and save first chunk
        newImageBeginning = remaining.indexOf(matches[0]) + matches[0].length
        @imageExpectedLength = matches[1]
        @data += remaining.substring newImageBeginning
      else if typeMatches?
        # If Content-Length is not present, but Content-Type is
        newImageBeginning = remaining.indexOf(typeMatches[0]) + typeMatches[0].length
        @data += remaining.substring newImageBeginning
      else
        newImageBeginning = boundary_index + @boundary.length
        @emit 'error',
          message: 'Could not find beginning of next image'
    else
      @data += chunk

    # Threshold to avoid memory over-consumption
    # E.g. if a boundary string is never found, 'data' will never stop consuming memory
    if @data.length >= @memory
      @data = ''
      @emit 'error',
        message: 'Data buffer just reached threshold, flushing memory'


module.exports = Paparazzo
