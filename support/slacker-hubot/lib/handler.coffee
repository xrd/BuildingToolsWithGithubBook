_SECRET = undefined

anyoneButProbot = (members) ->
        user = undefined
        while not user
                user = members[ parseInt( Math.random() * members.length ) ].name
                user = undefined if "probot" == user
        user

exports.prHandler = ( robot, req, res ) ->
        secret = req.body?.secret
        if secret == _SECRET
                url = req.body?.url
                room = "general"

                robot.http( "https://slack.com/api/users.list?token=#{process.env.HUBOT_SLACK_TOKEN}" )
                        .get() (err, response, body) ->
                                unless err
                                        parsed = JSON.parse( body )
                                        user = anyoneButProbot( parsed.members )
                                        robot.messageRoom room, "#{user}: Hey, want a PR? #{url}"

        else
                console.log "Invalid secret"
        res.send "OK\n"

exports.setSecret = (secret) ->
        _SECRET = secret
