describe( "GithubCtrl", function() {

    var scope = undefined, gh = undefined, repo = undefined, prompter = undefined;

    function generateMockPrompt() {
        prompter = { prompt: function() { return "ABC" } };
        spyOn( prompter, "prompt" ).andCallThrough();

    }

    var PR_ID = 12345;
    function generateMockRepositorySupport() {
        repo = { 
            fork: function( cb ) {
                cb( false );
            },
            write: function( branch, filename, data, commit_msg, cb ) {
                cb( false );
            },
            createPullRequest: function( pull, cb ) {
                cb( false, PR_ID );
            },
            read: function( branch, filename, cb ) {
                cb( undefined, JSON.stringify( filename == "cities.json" ? CITIES : PORTLAND ) );
            } 
        };
        spyOn( repo, "fork" ).andCallThrough();
        spyOn( repo, "write" ).andCallThrough();
        spyOn( repo, "createPullRequest" ).andCallThrough();
        spyOn( repo, "read" ).andCallThrough();

        gh = { getRepo: function() {} };
        spyOn( gh, "getRepo" ).andCallFake( function() {
            return repo;
        } );
        ghs = { create: function() { return gh; } };
    }

    beforeEach( module( "coffeetech" ) );

    var $timeout;
    beforeEach( inject( function ($controller, $rootScope, $injector ) {
        generateMockRepositorySupport();
        generateMockPrompt();
        $timeout = $injector.get( '$timeout' );
        scope = $rootScope.$new();
        ctrl = $controller( "GithubCtrl", { $scope: scope, Github: ghs, '$timeout': $timeout, '$window': prompter } );
    } ) );


    describe( "#annotate", function() {
        it( "should annotate a shop", function() {
            var shop = { name: "A coffeeshop" }
            scope.annotate( shop );
            expect( scope.shopToAnnotate ).toBeTruthy();
            expect( prompter.prompt.calls.length ).toEqual( 3 );
            expect( scope.username ).not.toBeFalsy();
            expect( scope.annotation ).not.toBeFalsy();

            expect( repo.fork ).toHaveBeenCalled();
            expect( scope.waiting.state ).toEqual( "forking" );
            $timeout.flush();

            expect( scope.forkedRepo ).toBeTruthy();
            expect( repo.read ).toHaveBeenCalled();
            expect( repo.write ).toHaveBeenCalled();
            expect( repo.createPullRequest ).toHaveBeenCalled();
            expect( scope.waiting.state ).toEqual( "annotated" );
            $timeout.flush();

            expect( scope.waiting ).toBeFalsy();
        });

    });
} );
