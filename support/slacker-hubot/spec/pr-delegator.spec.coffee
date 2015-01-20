
Probot = require "../scripts/pr-delegator"
Handler = require "../lib/handler"

pr = undefined
robot = undefined

describe "#probot", ->
        beforeEach () ->
                robot = {
                        respond: jasmine.createSpy()
                        router: {
                                post: jasmine.createSpy()
                                }
                        }

        it "should verify our calls to respond", (done) ->
                pr = Probot robot
                expect( robot.respond.calls.length ).toEqual( 2 )
                done()

        it "should verify our calls to router.post", (done) ->
                pr = Probot robot
                expect( robot.router.post ).toHaveBeenCalled()
                done()

        describe "#pr", ->
                secret = "ABCDEF"
                robot = undefined
                res = undefined
                
                beforeEach ->
                        robot = {
                                messageRoom: jasmine.createSpy()
                                }
                        res = { send: jasmine.createSpy() }
                        Handler.setSecret secret
                
                it "should disallow calls without the secret", (done) ->
                        req = {}
                        Handler.prHandler( robot, req, res )
                        expect( robot.messageRoom ).not.toHaveBeenCalled()
                        expect( res.send ).toHaveBeenCalled()
                        done()

                it "should allow calls with the secret", (done) ->
                        req = { body: { secret: secret } }
                        Handler.prHandler( robot, req, res )
                        expect( robot.messageRoom ).toHaveBeenCalled()
                        expect( res.send ).toHaveBeenCalled()
                        done()



        
