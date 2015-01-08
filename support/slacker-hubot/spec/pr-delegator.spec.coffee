
Probot = require "../scripts/pr-delegator"

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

        it "should verify our calls to respond and router.post", (done) ->
                pr = Probot robot
                expect( robot.respond.calls.length ).toEqual( 2 )
                expect( robot.router.post ).toHaveBeenCalled()
                done()


        
