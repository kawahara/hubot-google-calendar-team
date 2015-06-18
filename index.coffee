fs = require 'fs'
path = require 'path'

module.exports = (robot) ->
  p = path.resolve __dirname, 'scripts'
  fs.exists p, (exists) ->
    if exists
      robot.loadFile p, file for file in fs.readdirSync(p)
