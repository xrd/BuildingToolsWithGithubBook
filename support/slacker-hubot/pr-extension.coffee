module.exports = (robot) ->
        robot.hear /badger/i, (msg) ->
                msg.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

