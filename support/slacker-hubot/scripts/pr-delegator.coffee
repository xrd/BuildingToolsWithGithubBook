handler = require '../lib/handler'

handler.setSecret "XYZABC"
github = require 'github'
ginst = new github version: '3.0.0'
handler.setApiToken ginst, "e86d2f7df495be03bf32f67ea7f9ded3978cbf42"

module.exports = (robot) ->

        robot.respond /accept (.*)/i, ( req, res ) ->
                handler.accept( req, res )

        robot.respond /decline/i, ( res ) ->
                handler.decline( res )

        robot.router.post '/pr', ( req, res ) ->
                handler.prHandler( robot, req, res )
