path = require 'path'
{msgVariables, stringElseRandomKey} = require path.join '..', 'lib', 'common.coffee'

class say
  constructor: (@interaction) ->
  process: (msg) =>
    messageType = @interaction.messageType?.toLowerCase() or 'say'
    switch messageType
      when 'action', 'emote'
        messageType = 'emote'
      else
        messageType = 'send'

    message = stringElseRandomKey @interaction.message

    message = msgVariables message, msg
    msg[messageType] message

module.exports = say
