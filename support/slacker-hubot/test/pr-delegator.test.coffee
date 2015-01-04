Probot = require "../scripts/pr-delegator"

calledIt = false

msg = {
        send: () ->
                calledIt = true
        }

robot = {
        respond: ( re, cb ) ->
                cb()
        }

exports.acceptance =
        'verify acceptance': (test) ->
                pr = Probot( robot )
                test.ok( robot.respond )
                test.done()

        
