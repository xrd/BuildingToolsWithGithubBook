handler = require '../lib/handler'

handler.setSecret "XYZABC"

module.exports = (robot) ->

        robot.respond /accept/i, ( req, res ) ->
                handler.accept( req, res )

        robot.respond /decline/i, ( res ) ->
                handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
