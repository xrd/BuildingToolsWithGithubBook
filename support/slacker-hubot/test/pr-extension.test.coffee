PrDelegator = require "../pr-delegator"

robot = {
        hear: (text, func) ->
                func( { send: () -> "ada" } )
        response: () ->
                "something"
        }

exports.acceptance =
        'verify acceptance': (test) ->
                pr = PrHubot( robot )
                test.expect( pr.hear( "badger" ) )
                test.expect( 1 )
                test.ok true, "yeah, this is correct"
                test.done()

        
