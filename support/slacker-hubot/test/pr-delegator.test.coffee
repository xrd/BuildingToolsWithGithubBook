Pr = require "../scripts/pr-delegator"

calledIt = false

msg = {
        send: () ->
                calledIt = true
        }

robot = {
        hear: ( something, message ) -> msg
        }

exports.acceptance =
        'verify acceptance': (test) ->
                pr = Pr( robot )
                pr.hear( "" ) 
                test.expect( calledIt )
                test.done()

        
