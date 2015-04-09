handler = require '../lib/handler'

handler.setSecret "XYZABC"

util = require 'util'

module.exports = (robot) ->
        robot.respond /accept/i, ( res ) ->
                res.reply "OK, thanks"
                console.log( util.inspect( res ) )

        robot.respond /decline/i, ( res ) ->
                handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
