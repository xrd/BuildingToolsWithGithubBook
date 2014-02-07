describe( "GithubCtrl", function() {
    var scope = undefined;
    var ctrl = undefined;
    var gh  = undefined;
    var ghs = undefined;
    var repo = undefined;
    var geo = undefined;

    function generateMockGeolocationSupport( lat, lng ) {
        response = ( lat && lng ) ? { coords: { lat: lat, lng: lng } } : { coords: CITIES[0] };
        geo = { getCurrentPosition: function( success, failure ) {
            success( response );
        } };
        spyOn( geo, "getCurrentPosition" ).andCallThrough();
    }

    var prompter = undefined;
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
            write: function( branch, filename, data
            createPullRequest: function( pull, cb ) {
                cb( false, PR_ID );
            },
            read: function( branch, filename, cb ) {
                cb( undefined, JSON.stringify( filename == "cities.json" ? CITIES : PORTLAND ) );
            } 
        };
        spyOn( repo, "fork" ).andCallThrough();
        spyOn( repo, "createPullRequest" ).andCallThrough();
        spyOn( repo, "read" ).andCallThrough();

        gh = { getRepo: function() {} };
        spyOn( gh, "getRepo" ).andCallFake( function() {
            return repo;
        } );
        ghs = { create: function() { return gh; } };
    }

    beforeEach( module( "coffeetech" ) );

    beforeEach( inject( function ($controller, $rootScope ) {
        generateMockGeolocationSupport();
        generateMockRepositorySupport();
        generateMockPrompt();
        scope = $rootScope.$new();
        ctrl = $controller( "GithubCtrl", { $scope: scope, Github: ghs, Geo: geo, Prompt: prompter } );
    } ) );

    describe( "#init", function() {
        it( "should initialize, grabbing current city", function() {
            scope.init();
            expect( geo.getCurrentPosition ).toHaveBeenCalled();
            expect( gh.getRepo ).toHaveBeenCalled();
            expect( repo.read ).toHaveBeenCalled();
            expect( scope.cities.length ).toEqual( 2 );
            expect( scope.city.name ).toEqual( "portland" );
            expect( scope.shops.length ).toEqual( 3 );
        });
    });

    describe( "#calculateDistance", function() {
        it( "should find distance between two points", function() {
            expect( parseInt( scope.calculateDistance( 14.599512, 120.98422, 10.315699, 123.885437 ) * 0.621371 ) ).toEqual( 354 );
        });
    });

    describe( "#annotate", function() {
        var $timeout;
        beforeEach( inject( function( $injector ) {
            $timeout = $injector.get( '$timeout' );
            } ) );
        it( "should annotate a shop", function() {
            var shop = { name: "A coffeeshop" }
            scope.annotate( shop );
            expect( scope.shop_to_annotate ).toBeTruthy();
            expect( prompter.prompt.calls.length ).toEqual( 3 );
            expect( scope.username ).not.toBeFalsy();
            expect( scope.annotation ).not.toBeFalsy();

            expect( repo.fork ).toHaveBeenCalled();
            expect( scope.forked_repo ).toBeTruthy();
            expect( scope.waiting.state ).toEqual( "forking" );
            $timeout.flush();

            expect( repo.read ).toHaveBeenCalled();
            expect( repo.createPullRequest ).toHaveBeenCalled();
            expect( scope.waiting.state ).toEqual( "annotated" );
            $timeout.flush();

            expect( scope.waiting.state ).toBeFalsy();
        });

    });

});
