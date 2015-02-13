path = require 'path'
Forecast = require 'forecast'
{msgVariables, applyVariable, stringElseRandomKey} = require path.join '..', 'lib', 'common.coffee'

class forecast
  constructor: (@interaction) ->
    @forecast = new Forecast
      service: 'forecast.io'
      key: process.env.HEARTBOT_FORECAST_API_KEY
      units: @interaction.units
      cache: true
      ttl:
        minutes: 25
        seconds: 0

    {@latitude, @longitude} = @interaction.location
  process: (msg) =>
    @forecast.get [@latitude, @longitude], (err, weather) =>
      return if err

      temperature = Math.round weather.currently.temperature
      message = stringElseRandomKey @interaction.message

      message = msgVariables message, msg
      message = applyVariable message, 'temperature', temperature
      message = applyVariable message, 'units', @interaction.units

      msg.send message

module.exports = forecast
