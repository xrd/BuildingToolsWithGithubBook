_SECRET = undefined

exports.prHandler = ( robot, req, res ) ->
        secret = req.body?.secret
        if secret == _SECRET
                room = "general"
                robot.messageRoom room, "OMG, GitHub is on my caller-id!?!"
        res.send 'OK'


exports.setSecret = (secret) ->
        _SECRET = secret
