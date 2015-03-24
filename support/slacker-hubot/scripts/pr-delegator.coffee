handler = require '../lib/handler'

handler.setSecret "XYZABC"

module.exports = (robot) ->
        robot.respond /accept/i, (msg) ->
                accept( msg )

        robot.respond /decline/i, (msg) ->
                decline( msg )

        accept = ( msg ) ->
                msg.reply "Thanks, you got it!"
                console.log "Accepted!"
                
        decline = ( msg ) ->
                msg.reply "OK, I'll find someone else"
                console.log "Declined!"

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
