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

getSecureHash = (body, secret) ->
        hash = crypto.createHmac( 'sha1', secret ).update( "sha1=" + body ).digest('hex')
        console.log "Hash: #{hash}"
        hash

exports.prHandler = ( robot, req, res ) ->
        body = req.body
        pr = JSON.parse body if body
        url = pr.pull_request.url if pr
        secureHash = getSecureHash( body, _SECRET ) if body
        webhookProvidedHash = req.headers['HTTP_X_HUB_SIGNATURE' ] if req?.headers
        secureCompare = require 'secure-compare'

        if secureCompare( secureHash, webhookProvidedHash ) and url
                room = "general"
                robot.http( "https://slack.com/api/users.list?token=#{process.env.HUBOT_SLACK_TOKEN}" )
                        .get() (err, response, body) ->
                                sendPrRequest( robot, body, room, url ) unless err
        else
                console.log "Invalid secret or no URL specified"
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
        "username"

exports.accept = ( res ) ->

        msg = exports.decodePullRequest( _PR_URL )
        username = exports.getUsernameFromResponse( res )
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
