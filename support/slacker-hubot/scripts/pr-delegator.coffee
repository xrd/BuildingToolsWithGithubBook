handler = require '../lib/handler'

handler.setSecret "XYZABC"

util = require 'util'

module.exports = (robot) ->
        robot.respond /accept/i, ( res ) ->
                res.reply "OK, thanks"
                for key in Object.keys( res )
                        console.log "#{key}: #{res[key]}"
                console.log "Message: #{res.message}"
                console.log( util.inspect( res ) )
                # handler.accept( res )

        robot.respond /decline/i, ( res ) ->
                #handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
