message_types = require('./internal').message_types
ConnectionMonitor = require('./connection_monitor')

class Connection
  @reopenDelay: 500

  constructor: (@consumer) ->
    {@subscriptions} = @consumer
    @monitor = new ConnectionMonitor(@)
    @disconnected = true

  send: (data) ->
    if @isOpen()
      @webSocket.send(JSON.stringify(data))
      true
    else
      false

  open: =>
    if @isActive()
      throw new Error('Existing connection must be closed before opening')
    else
      @uninstallEventHandlers() if @webSocket?
      @webSocket = new WebSocket(@consumer.url)
      @installEventHandlers()
      @monitor.start()
      true

  close: ({allowReconnect} = {allowReconnect: true}) ->
    @monitor.stop() unless allowReconnect
    @webSocket?.close() if @isActive()

  reopen: ->
    if @isActive()
      try
        @close()
      finally
        setTimeout(@open, @constructor.reopenDelay)
    else
      @open()

  getProtocol: ->
    @webSocket?.protocol

  isOpen: ->
    @isState("open")

  isActive: ->
    @isState("open", "connecting")

  # Private

  isState: (states...) ->
    @getState() in states

  getState: ->
    return state.toLowerCase() for state, value of WebSocket when value is @webSocket?.readyState
    null

  installEventHandlers: ->
    for eventName of @events
      handler = @events[eventName].bind(this)
      @webSocket["on#{eventName}"] = handler
    return

  uninstallEventHandlers: ->
    for eventName of @events
      @webSocket["on#{eventName}"] = ->
    return

  events:
    message: (event) ->
      {identifier, message, type} = JSON.parse(event.data)
      switch type
        when message_types.welcome
          @monitor.recordConnect()
          @subscriptions.reload()
        when message_types.ping
          @monitor.recordPing()
        when message_types.confirmation
          @subscriptions.notify(identifier, "connected")
        when message_types.rejection
          @subscriptions.reject(identifier)
        else
          @subscriptions.notify(identifier, "received", message)

    open: ->
      @disconnected = false

    close: (event) ->
      return if @disconnected
      @disconnected = true
      @monitor.recordDisconnect()
      @subscriptions.notifyAll("disconnected", {willAttemptReconnect: @monitor.isRunning()})

    error: ->
      #

module.exports = Connection
