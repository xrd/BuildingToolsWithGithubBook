_SECRET = undefined

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

exports.prHandler = ( robot, req, res ) ->
        secret = req.body?.secret
        url = req.body?.url

        if secret == _SECRET and url
                room = "general"
                robot.http( "https://slack.com/api/users.list?token=#{process.env.HUBOT_SLACK_TOKEN}" )
                        .get() (err, response, body) ->
                                sendPrRequest( robot, body, room, url ) unless err
        else
                console.log "Invalid secret or no URL specified"
        res.send "OK\n"

exports.setSecret = (secret) ->
        _SECRET = secret
