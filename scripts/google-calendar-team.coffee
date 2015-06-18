fs = require('fs')
Google = require('googleapis')
GoogleAuth = require('google-auth-library')

module.exports = (robot) ->
  robot.respond /schedule (.*) at (.*)( (.*))?/, (msg) ->
    getCalendar msg.envelope.user.name, true, (err, data) ->
      if err
        return
      name = msg.match[1]
      time = msg.match[2]
      day = msg.match[4]
      addEvent data.id, name, time, day, (err, data) ->


  robot.respond /cancel a schedule at (.*)/, (msg) ->

  robot.respond /show me schedule( for (.*))?/, (msg) ->
    getCalendar msg.envelope.user.name, false, (err, data) ->
      robot.logger.info data

      if err
        return

      unless data
        return

      calendarApi.events.list(
        {
          calendarId: data.id
        }, (err, data)->
          robot.logger.error err
          robot.logger.info data
          for item in data.items
            robot.logger.info item.summary
            robot.logger.info item.start
            robot.logger.info item.end
      )


  managedCalendars = []

  auth = new GoogleAuth()
  oauth2 = new auth.OAuth2()
  calendarApi = null


  getCalendar = (name, isCreate, callback) ->
    for calendar in managedCalendars
      if (calendar.userName == name)
        callback(null, calendar)
        return

    if (!isCreate)
      callback(null, null)
      return

    robot.logger.info "Making #{name}@#{robot.name}"
    calendarApi.calendars.insert(
      {
        resource: {
          summary: "#{name}@#{robot.name}"
        }
      },
      (err, data) ->
        if err
          robot.logger.error err
          callback(err, null)
          return

        robot.logger.info data
        data.userName = name
        managedCalendars.push data
    )


  fs.readFile 'token.json', (err, contents) ->
    if err
      robot.logger.error err
      return

    robot.logger.info JSON.parse contents
    oauth2.credentials = JSON.parse contents
    Google.options({
      auth: oauth2
    })

    calendarApi = Google.calendar('v3')

    calendarApi.calendarList.list {
    }, (err, data) ->
      if (err)
        robot.logger.error err
        return
      for calendar in data.items
        matched = calendar.summary.match(
          "^(.*)@#{robot.name.replace(/\W/g, '\\$&')}$"
        )
        if (matched)
          calendar.userName = matched[1]
          robot.logger.info calendar
          managedCalendars.push calendar
      robot.logger.info 'Ready to use google calendar.'

