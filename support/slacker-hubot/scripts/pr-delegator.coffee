handler = require '../lib/handler'

handler.setSecret "XYZABC"

module.exports = (robot) ->

        # Setup our own express handler
        express = require 'node_modules/hubot/node_modules/express/lib/express'
        robot.express = app = express()
        
        robot.respond /accept/i, ( res ) ->
                res.reply "OK, thanks"

        robot.respond /decline/i, ( res ) ->
                handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
