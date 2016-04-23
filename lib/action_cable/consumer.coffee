Connection = require('./connection')
ConnectionMonitor = require('./connection_monitor')
Subscriptions = require('./subscriptions')

class Consumer
  constructor: (@url) ->
    @subscriptions = new Subscriptions this
    @connection = new Connection this
    @connectionMonitor = new ConnectionMonitor this

  send: (data) ->
    @connection.send(data)

module.exports = Consumer
