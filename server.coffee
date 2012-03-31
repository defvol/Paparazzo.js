# Using the Paparazzo.js module

Paparazzo = require './paparazzo'

options = 
        host: 'algodones1.dyndns.biz'
    ,   port: 6531
    ,   path: '/video2.mjpg'
    ,   headers: 
        'Authorization': 'Basic ' + new Buffer('monkeycat:squal0!').toString('base64')
        
paparazzo = Paparazzo.init options, (error) ->
    console.log "#{error.message}" if error?
    
paparazzo.start (error) ->
    console.log "#{error.message}" if error?
    
    