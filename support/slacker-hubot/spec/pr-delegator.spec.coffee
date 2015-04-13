
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
                        req = { body: '{ "pull_request" : { "url" : "http://pr/1" }}', headers: { "HTTP_X_HUB_SIGNATURE" : "cd970490d83c01b678fa9af55f3c7854b5d22918" } }
                        Handler.prHandler( robot, req, res )
                        expect( robot.messageRoom ).toHaveBeenCalled()
                        expect( httpSpy ).toHaveBeenCalled()
                        expect( res.send ).toHaveBeenCalled()
                        done()

                describe "#response", ->
                        createComment = jasmine.createSpy( 'createComment' ).and.
                                callFake( ( msg, cb ) -> cb( false, "some data" ) )
                        issues = { createComment: createComment }
                        authenticate = jasmine.createSpy( 'ghAuthenticate' )
                        responder = { reply: jasmine.createSpy( 'reply' ),
                        send: jasmine.createSpy( 'send' ),
                        message: { user: { name: "Chris Dawson" } } }
                        collaborators = [ { username: "Chris Dawson" }, { username: "Ben Straub" } ]
                        getCollaborators = jasmine.createSpy( 'getCollaborators' ).and.
                                callFake( ( msg, cb ) -> cb( false, collaborators ) )
                        repos = { getCollaborators: getCollaborators }

                        beforeEach ->
                                githubBinding = { authenticate: authenticate, issues: issues, repos: repos }
                                github = Handler.setApiToken( githubBinding, "ABCDEF" )
                                req = { body: '{ "pull_request" : { "url" : "http://pr/1" }}', headers: { "HTTP_X_HUB_SIGNATURE" : "cd970490d83c01b678fa9af55f3c7854b5d22918" } }
                                Handler.prHandler( robot, req, responder )

                        it "should tag the PR on GitHub if the user accepts", (done) ->
                                Handler.accept( responder )
                                expect( authenticate ).toHaveBeenCalled()
                                expect( createComment ).toHaveBeenCalled() 
                                expect( responder.reply ).toHaveBeenCalled()
                                expect( repos.getCollaborators ).toHaveBeenCalled()
                                done()

                        it "should not tag the PR on GitHub if the user declines", (done) ->
                                Handler.decline( responder )
                                expect( authenticate ).toHaveBeenCalled()
                                expect( createComment ).not.toHaveBeenCalledWith()
                                expect( responder.reply ).toHaveBeenCalled()
                                done()

                        it "should decode the URL into a proper message object for the createMessage call", (done) ->
                                url = "https://github.com/xrd/testing_repository/pull/1"
                                msg = Handler.decodePullRequest( url )
                                expect( msg.user ).toEqual( "xrd" )
                                expect( msg.repository ).toEqual( "testing_repository" )
                                expect( msg.number ).toEqual( "1" )
                                done()
                                
                        it "should get the username from the response object", (done) ->
                                expect( Handler.getUsernameFromResponse( responder ) ).toEqual "Chris Dawson"
                                done()



        
