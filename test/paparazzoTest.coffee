# To run:
# $ mocha --compilers coffee:coffee-script -R spec

chai = require 'chai'
chai.should()
expect = chai.expect

Paparazzo = require '../src/paparazzo'

paparazzo = null

describe 'Paparazzo constructor', ->
    it 'should assign port 80 by default', ->
        paparazzo = new Paparazzo
            host: '85.105.120.239'
        paparazzo.options.port.should.equal 80
    it 'should looked after "/" by default', ->
        paparazzo = new Paparazzo
            host: '85.105.120.239'
        paparazzo.options.path.should.equal '/'

