
Probot = require "../scripts/pr-delegator"
Handler = require "../lib/handler"

pr = undefined
robot = undefined

describe "#probot", ->
        beforeEach () ->
                robot = {
                        respond: jasmine.createSpy( 'respond' )
                        router: {
                                post: jasmine.createSpy( 'post' )
                                }
                        }

        it "should verify our calls to respond", (done) ->
                pr = Probot robot
                expect( robot.respond.calls.count() ).toEqual( 2 )
                done()

        it "should verify our calls to router.post", (done) ->
                pr = Probot robot
                expect( robot.router.post ).toHaveBeenCalled()
                done()

        describe "#pr", ->
                secret = "ABCDEF"
                robot = undefined
                res = undefined
                # req = { body: '{ "pull_request" : { "url" : "http://pr/1" } }', headers: { 'HTTP_X_HUB_SIGNATURE' : "ABC" } }

                json = '{ "members" : [ { "name" : "bar" } , { "name" : "foo" } ] }'
                httpSpy = jasmine.createSpy( 'http' ).and.returnValue(
                        { get: () -> ( func ) ->
                                func( undefined, undefined, json ) } )
                
                beforeEach ->
                        robot = {
                                messageRoom: jasmine.createSpy( 'messageRoom' )
                                http: httpSpy
                                }
                                
                        res = { send: jasmine.createSpy( 'send' ) }
                        Handler.setSecret secret
                
                it "should disallow calls without the secret and url", (done) ->
                        req = {}
                        Handler.prHandler( robot, req, res )
                        expect( robot.messageRoom ).not.toHaveBeenCalled()
                        expect( httpSpy ).not.toHaveBeenCalled()
                        expect( res.send ).toHaveBeenCalled()
                        done()

                it "should allow calls with the secret and url", (done) ->
                        req = { body: '{ "pull_request" : { "url" : "http://pr/1" }}', headers: "ENTER_HMAC_HASH" }
                        Handler.prHandler( robot, req, res )
                        expect( robot.messageRoom ).toHaveBeenCalled()
                        expect( httpSpy ).toHaveBeenCalled()
                        expect( res.send ).toHaveBeenCalled()
                        done()



        
