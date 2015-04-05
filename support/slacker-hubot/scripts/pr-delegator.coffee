handler = require '../lib/handler'

handler.setSecret "XYZABC"

module.exports = (robot) ->
        robot.respond /accept/i, ( res ) ->
                handler.accept( res )

        robot.respond /decline/i, ( res ) ->
                handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
