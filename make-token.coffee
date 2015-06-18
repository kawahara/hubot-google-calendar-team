fs = require 'fs'
readline = require 'readline'
GoogleAuth = require 'google-auth-library'

storeToken = (token) ->
  fs.writeFileSync('token.json', JSON.stringify(token))

getNewToken = (oauth2Client, callback) ->
  authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline'
    scope: ['https://www.googleapis.com/auth/calendar']
  })
  console.log 'Authorize this app by visiting this url: ', authUrl
  r1 = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  })
  r1.question('Enter the code from that page here: ', (code) ->
    r1.close()
    oauth2Client.getToken(code, (err, token) ->
      if (err)
        console.log 'Error while trying to retrieve access token', err
        process.exit 1
        return

      oauth2Client.credentials = token
      storeToken(token)
      callback()
    )
  )


authorize = (credentials, callback) ->
  clientId = credentials.installed.client_id
  clientSecret = credentials.installed.client_secret
  redirectUrl = credentials.installed.redirect_uris[0]
  auth = new GoogleAuth()
  oauth2Client = new auth.OAuth2(clientId, clientSecret, redirectUrl)
  getNewToken(oauth2Client, callback)

fs.readFile('client_secret.json', (err, content)->
  if (err)
    console.log 'Error loading client secret file:' + err
    return

  authorize(JSON.parse(content), ()->
    console.log 'Complate to authorize with Google account! Thank you!'
    process.exit 0
  )
)
