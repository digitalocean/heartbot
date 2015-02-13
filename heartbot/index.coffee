fs = require 'fs'
path = require 'path'

config = {}
events = {}

{regexEscape} = require path.join '..', 'lib', 'common.coffee'

eventsPath = path.join __dirname, '..', 'events'
for event in fs.readdirSync(eventsPath).sort()
  events[event.replace /\.coffee$/, ''] = require path.join eventsPath, event

module.exports = (_config, robot) ->
  config = _config
  if not config.interactions?.length
    robot.logger.warning 'No heartbot interactions configured.'
    return

  config.interactions.forEach (interaction) ->
    {event, pattern} = interaction
    if not events.hasOwnProperty event
      console.log "Unknown event #{event}"
      return

    event = new events[event] interaction
    event._heartbot_first_run = true
    callback = event.process
    regex = pattern.regex.replace '##heartbot##', regexEscape robot.name
    trigger = interaction.trigger or 'hear'

    robot[trigger] new RegExp(regex, pattern.options or ''), do (event, interaction, callback) ->
      ->
        if event._heartbot_first_run or Math.random() < (interaction.probability or config.probability)
          callback.apply @, arguments
          event._heartbot_first_run = false