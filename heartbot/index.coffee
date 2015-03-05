fs = require 'fs'
yaml = require 'js-yaml'
path = require 'path'

config = {}
events = {}

hubotPath = module.parent.filename
hubotPath = path.dirname hubotPath for [1..3]

{regexEscape} = require path.join '..', 'lib', 'common.coffee'

eventsPath = path.join __dirname, '..', 'events'
for event in fs.readdirSync(eventsPath).sort()
  events[event.replace /\.coffee$/, ''] = require path.join eventsPath, event

module.exports = (_config, robot) ->
  config = _config

  if config.events?.length
    config.events.forEach (externalEvents) ->
      eventPath = path.join hubotPath, externalEvents
      eventFile = externalEvents.replace /(.)+\//, ''
      events[eventFile.replace /\.coffee$/, ''] = require path.join hubotPath, externalEvents
  else
    robot.logger.warning 'No custom events defined.'
    return

  if not config.patterns?.length
    robot.logger.warning 'No heartbot interactions configured.'
    return

  config.patterns.forEach (pattern) ->
    patternPath = path.join hubotPath, pattern
    try
      patternFile = yaml.safeLoad fs.readFileSync patternPath, 'utf8'
    catch err
      console.error "An error occurred while trying to load Heartbot's interactions."
      console.error err
      return

    patternFile.interactions.forEach (interaction) ->
      {event, pattern} = interaction
      if not events.hasOwnProperty event
        console.log "Unknown event #{event}"
        return

      event = new events[event] interaction
      event._heartbot_first_run = true
      callback = event.process
      regex = pattern.regex.replace '##heartbot##', regexEscape robot.name
      trigger = interaction.trigger or 'hear'

      robot[trigger] new RegExp(regex, pattern.options or 'i'), do (event, interaction, callback) ->
        ->
          if event._heartbot_first_run or Math.random() < (interaction.probability or config.probability)
            callback.apply @, arguments
            event._heartbot_first_run = false
