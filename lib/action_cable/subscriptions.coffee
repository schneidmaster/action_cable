identifiers = require('./internal').identifiers
Subscription = require('./subscription')

class Subscriptions
  constructor: (@consumer) ->
    @subscriptions = []

  create: (channelName, mixin) ->
    channel = channelName
    params = if typeof channel is "object" then channel else {channel}
    new Subscription(@, params, mixin)

  # Private

  add: (subscription) ->
    @subscriptions.push(subscription)
    @notify(subscription, "initialized")
    @sendCommand(subscription, "subscribe")

  remove: (subscription) ->
    @forget(subscription)

    unless @findAll(subscription.identifier).length
      @sendCommand(subscription, "unsubscribe")

  reject: (identifier) ->
    for subscription in @findAll(identifier)
      @forget(subscription)
      @notify(subscription, "rejected")

  forget: (subscription) ->
    @subscriptions = (s for s in @subscriptions when s isnt subscription)

  findAll: (identifier) ->
    s for s in @subscriptions when s.identifier is identifier

  reload: ->
    for subscription in @subscriptions
      @sendCommand(subscription, "subscribe")

  notifyAll: (callbackName, args...) ->
    for subscription in @subscriptions
      @notify(subscription, callbackName, args...)

  notify: (subscription, callbackName, args...) ->
    if typeof subscription is "string"
      subscriptions = @findAll(subscription)
    else
      subscriptions = [subscription]

    for subscription in subscriptions
      subscription[callbackName]?(args...)

  sendCommand: (subscription, command) ->
    {identifier} = subscription
    if identifier is identifiers.ping
      @consumer.connection.isOpen()
    else
      @consumer.send({command, identifier})

module.exports = Subscriptions
