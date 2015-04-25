handler = require '../lib/handler'

handler.setSecret "XYZABC"

module.exports = (robot) ->

        robot.respond /accept/i, ( req, res ) ->
                handler.accept( req, res )
                res.reply "OK, thanks"

        robot.respond /decline/i, ( res ) ->
                handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                console.log "got pr"
                handler.prHandler( robot, req, res )
