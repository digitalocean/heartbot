path = require 'path'
Giphy = require 'giphy'
{msgVariables, applyVariable} = require path.join '..', 'lib', 'common.coffee'

class giphy
  constructor: (@interaction) ->
    @giphy = new Giphy (process.env.HEARTBOT_GIPHY_API_KEY or 'dc6zaTOxFJmzC')
  process: (msg) =>
    @giphy.random {
      tag: @interaction.tag
      rating: @interaction.rating or 'g'
    }, (err, res) =>
      if err
        console.log err
        return

      gif = res.data.url
      return unless gif

      message = msgVariables @interaction.message, msg
      message = applyVariable message, 'gif', gif

      msg.send message

module.exports = giphy
