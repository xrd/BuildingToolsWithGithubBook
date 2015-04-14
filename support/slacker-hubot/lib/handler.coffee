_SECRET = undefined
crypto = require 'crypto'
_API_TOKEN = undefined

anyoneButProbot = (members) ->
        user = undefined
        while not user
                user = members[ parseInt( Math.random() * members.length ) ].name
                user = undefined if "probot" == user
        user

sendPrRequest = ( robot, body, room, url ) ->
        parsed = JSON.parse( body )
        user = anyoneButProbot( parsed.members )
        robot.messageRoom room, "#{user}: Hey, want a PR? #{url}"

getSecureHash = ( body ) ->
        hmac = crypto.createHmac( 'sha1', _SECRET )
        hmac.setEncoding( 'hex' )
        hmac.write( body )
        hmac.end()
        hash = hmac.read()
        console.log "Hash: #{hash}"
        hash

exports.prHandler = ( robot, req, res ) ->
        util = require 'util'
        fs = require 'fs'
        inspected = util.inspect( req )
        fs.writeFile "request.txt", inspected, (err) ->
                if err
                        console.log "Unable to write"
        # console.log "Body: " + util.inspect( req.body )

        jsonBody = req.body
        json = req.body.payload
        pr = JSON.parse json
        if pr.pull_request
                url = pr.pull_request.url if pr
                secureHash = getSecureHash( "payload=#{encodeURIComponent(json)}" )
                signatureKey = "x-hub-signature"
                webhookProvidedHash = req.headers[ signatureKey ] if req?.headers
                console.log "WebHook Hash: #{webhookProvidedHash}"
                secureCompare = require 'secure-compare'
        
                if secureCompare( secureHash, webhookProvidedHash ) and url
                        room = "general"
                        robot.http( "https://slack.com/api/users.list?token=#{process.env.HUBOT_SLACK_TOKEN}" )
                                .get() (err, response, body) ->
                                        sendPrRequest( robot, body, room, url ) unless err
                else
                        console.log "Invalid secret or no URL specified"
        else
                console.log "No pull request in here"
        res.send "OK\n"

_GITHUB = undefined
_PR_URL = undefined

exports.decodePullRequest = (url) ->
        rv = {}
        if url
                chunks = url.split "/"
                if chunks.length == 7
                        rv.user = chunks[3]
                        rv.repository = chunks[4]
                        rv.number = chunks[6]
        rv

exports.getUsernameFromResponse = ( res ) ->
        res.message.user.name

exports.usernameMatchesGitHubUsernames = ( name, collaborators ) ->
        rv = false
        console.log( "Collaborators: #{ require( 'util' ).inspect( collaborators ) }" )
        for collaborator in collaborators
                if collaborator.username == name
                        rv = true
        rv

exports.accept = ( res ) ->

        msg = exports.decodePullRequest( _PR_URL )
        username = exports.getUsernameFromResponse( res )

        _GITHUB.repos.getCollaborators msg, ( err, collaborators ) ->
                if exports.usernameMatchesGitHubUsernames( username, collaborators )
                
                        msg.body = "@#{username} will review this (via Probot)."
                
                        _GITHUB.issues.createComment msg, ( err, data ) ->
                                unless err
                                        res.reply "Thanks, I've noted that in a PR comment!"
                                else
                                        res.reply "Something went wrong, I could not tag you on the PR comment"
                
exports.decline = ( res ) ->
        res.reply "OK, I'll find someone else."
        console.log "Declined!"

exports.setApiToken = (github, token) ->
        _API_TOKEN = token
        _GITHUB = github
        _GITHUB.authenticate type: "oauth", token: token

exports.setSecret = (secret) ->
        _SECRET = secret
