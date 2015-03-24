_SECRET = undefined

exports.prHandler = ( robot, req, res ) ->
        secret = req.body?.secret
        if secret == _SECRET
                console.log "Secret verified, let's notify our channel"
                room = "general"
                robot.messageRoom room, "OMG, GitHub is on my caller-id!?!"
        res.send "OK\n"

exports.setSecret = (secret) ->
        _SECRET = secret
