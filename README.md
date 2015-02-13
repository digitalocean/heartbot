# <img src="https://raw.githubusercontent.com/digitalocean/heartbot/master/heartbot.png" height="36" width="36"> Heartbot

Heartbot is a [Hubot](https://hubot.github.com/) integration that can be plugged into Slack, Hipchat, IRC, or other chat clients. Once installed, type things like "ugh", ":(", or "kitty me" and Heartbot will bring a little love and joy into the room. Spread the love on Twitter with #heartbot

## Getting Started

First, you need to have NodeJS installed on your server:

- Ubuntu: [How To Install Node.js on an Ubuntu 14.04 server](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server)
- CentOS: [How To Install Node.js on a CentOS 7 server](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-a-centos-7-server)

Then, you will want to install Hubot. Start by installing the `yo` and `generator-hubot` packages globally:

```
sudo npm install -g yo generator-hubot
```

Generate a Hubot instance:

```
mkdir heartbot
cd heartbot
yo hubot
```

You will be prompted for to choose a chat adapter. A list of chat adapters can be found [here](https://github.com/github/hubot/blob/master/docs/adapters.md). For example, to install the Slack chat adapter, run the following command:

```
npm install hubot-slack --save
```

Then, [create a Hubot service](http://my.slack.com/services/new/hubot) and copy the API token.

Next, install heartbot. While still in the `heartbot` directory, run:

```
npm install hubot-heartbot --save
cp node_modules/hubot-heartbot/config.yml heartbot.config.yml
```

To enable the Heartbot Hubot plugin, add `hubot-heartbot` to `external-scripts.json`:

```json
...
  "hubot-youtube",
  "hubot-heartbot"
]
```

Sign up for [forecast.io](https://developer.forecast.io/) and copy your API key.

Finally, start Heartbot:

```
HUBOT_SLACK_TOKEN=slack-token-here HEARTBOT_FORECAST_API_KEY=forecast.io-api-token-here ./bin/hubot -a slack
```

## Configuring Interactions

Heartbot comes with [a number of interactions pre-configured](interactions.md). Heartbot's configuration file, `heartbot.config.yml`, can be found in your Hubot instance's root directory.

```yaml
---
probability: 0.6
interactions:
    - pattern:
        ...

    - pattern:
        ...
```

The two main keys in the configuration file are:

### probability

A number between 0-1 that specifies the probability of Heartbot responding to a trigger. Setting it to 0 disables all interaction, while setting it to 1 makes Heartbot respond to all interactions at all times. Setting it to .5 would ensure that Heartbot would respond half the time to interactions.
                 
This is done so that Heartbot does not get overly annoying in busy channels/rooms.

In addition, a single interaction's probability can be modified independently of the global probability setting. You can do that by passing a `probability` key to the interaction.
                 
### interactions
 
A list of interactions that Heartbot should respond to.

An interaction should be written in the following format:

```yaml
- pattern:
    regex: >-
      ((what|who)('?s| is) |\?)##heartbot##
  event: say
  message: I'm Heartbot, a Hubot integration that is here to bring a little love and joy into the room.
  probability: 1
```

#### pattern

The `pattern` object should include a `regex` key and, optionally, an `options` key, which describe the RegEx pattern that should be match in order to trigger the interaction.

* `regex`: The text of the regular expression. You can use `##heartbot##` in the pattern to match the bot's name, which will be replaced with the bot's name once the interaction is loaded.
* `options`: Defaults to `i`. If specified, it can be a combination of any of the following values: `g`, `i`, `m`, and `y`. However, in this case, Heartbot would only benefit from the `i` option, which would make the RegEx pattern case-insensitive. You can find some details on the other options [here](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/RegExp).

#### message

The text that the interaction should respond with. This is usually a string, but can be an array of strings out of which a random message is picked depending on whether or not the event supports that, which the three events that Heartbot comes with (in the `events` directory) do.

There are a number of variables that can be used:

* `$user`: The name of the user who triggered the interaction.
* `$room`: The room/channel which the user triggered the interaction in.
* `$heartbot`: The bot's name.

#### event

The name of the event that should be called once the interaction is triggered. Heartbot ships with three events (see the `events` directory):

##### say

Simply a message that Heartbot should respond with. Other than the variables described above, no additional processing is done.

The `say` event can accept an optional option:

* `messageType`: How to actually respond. Can be either `say` (the default) or `action`.

##### forecast

Fetch the temperature in a specific location and respond with the `message`. Two additional keys are required:

* `location`: An object of the `latitude` and `longitude` of the location.
* `units`: Which units to use, can be either `F` or `C`.

In addition to these two keys, a [forecast.io API key](https://developer.forecast.io/) is required. You can pass the API key in an environment variable called `HEARTBOT_FORECAST_API_KEY`.

The `forecast` event supplies two variables to the `message`:

* `$temperature`: The temperature in the said location.
* `$units`: The units used.

For example, to fetch the temperature in *Oymyakon, Russia*:

```yaml
- pattern:
    ...
  event: forecast
  message: It could be worse. It’s currently $temperature° $units in Oymyakon, Russia
  location:
    latitude: 63.460833
    longitude: 142.785833
  units: C
```

##### giphy

Search [Giphy](http://giphy.com) for a random gif based on a specific search query.

The `giphy` event expects two options:

* `tag`: The search query.
* `rating`: Defaults to `g`. Limits search results to those rated `y`, `g`, `pg`, `pg-13`, or `r`.

If you are using Heartbot in production, you should pass an API key as the public API key that is used by default is subject to rate limiting and is intended only for development usage.

Please see [Giphy API Documentation > Access and API Keys](https://github.com/Giphy/GiphyAPI#access-and-api-keys). The API key can be passed using the environment variable `HEARTBOT_GIPHY_API_KEY`.

```yaml
- pattern:
    regex: ^puppy me$
  event: giphy
  tag: cute puppy
  message: Here's a puppy: $gif
```

### probability

A single interaction's probability can be overridden to make it different from the global probability value. Simply pass a `probability` key with the new probability value:

```yaml
- pattern:
    regex: ^puppy me$
  event: giphy
  tag: cute puppy
  message: Here's a puppy: $gif
  probability: 1
```

## Extending Heartbot

It is possible to write and use custom events. Events are written in [CoffeeScript](http://coffeescript.org/) and should export a class with a method called `process`. The rest is entirely up to you.

The `constructor` is passed the `interaction` object from the configuration file.

The `process` method is called with one argument: `msg`, an instance of Hubot's Response class. Please see [Hubot's official documentation on it](https://github.com/github/hubot/blob/master/docs/scripting.md#send--reply).

A few helper functions are included in `lib/common.coffee`:

**`applyVariable = (string, variable, value, regexFlags = 'i')`**

* `string`: A string/template which the variable should be added to.
* `variable`: The variable's name.
* `value`: The variable's value.
* `regexFlags`: Defaults to `i`. The flags that are used to match `variable` in `string`.

For example:

```coffeescript
string = 'Hello, $user!'

applyVariable string, 'user', 'Jane'
# 'Hello, Jane!'
```

**`msgVariables = (message, msg)`**

* `message`: A string/template which the variables should be added to.
* `msg`: The `msg` variable that is passed to [the `process` method](#adding-events).

This function provides [a few variables](#message) from `msg` to `message`.

**`stringElseRandomKey = (variable)`**

If `variable` is a string, it is simply returned back. However, if it is an array, a random item is returned.

**`regexEscape = (string)`**

Escape `string` so that it can safely be used in a RegEx pattern.
