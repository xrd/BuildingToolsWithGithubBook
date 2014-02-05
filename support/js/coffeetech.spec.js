describe( "GithubCtrl", function() {
    var scope = undefined;
    var ctrl = undefined;
    var gh  = undefined;
    var repo = undefined;
    var geo = undefined;

    function generateMockGeolocationSupport( lat, lng ) {
        response = ( lat && lng ) ? { coords: { lat: lat, lng: lng } } : { coords: CITIES[0] };
        geo = { getCurrentPosition: function( success, failure ) {
            success( response );
        } };
        spyOn( geo, "getCurrentPosition" ).andCallThrough();
    }

    var prompt = undefined;
    function generateMockPrompt() {
        prompt = { prompt: function() { return "ABC" } };
        spyOn( prompt, "prompt" ).andCallThrough();
    }

    var PR_ID = 12345;
    function generateMockRepositorySupport() {
        repo = { 
            fork: function( cb ) {
                cb( true );
            },
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

        gh = new Github({});
        spyOn( gh, "getRepo" ).andCallFake( function() {
            return repo;
        } );
    }

    beforeEach( module( "coffeetech" ) );

    beforeEach( inject( function ($controller, $rootScope ) {
        generateMockGeolocationSupport();
        generateMockRepositorySupport();
        generateMockPrompt();
        scope = $rootScope.$new();
        ctrl = $controller( "GithubCtrl", { $scope: scope, Github: gh, Geo: geo, prompt: prompt } );
    } ) 
    );

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
            scope.annotate();
            expect( prompt.prompt.calls.length ).toEqual( 3 );
            expect( repo.fork ).toHaveBeenCalled();
            $timeout.flush();
            expect( repo.read ).toHaveBeenCalled();
            expect( repo.createPullRequest ).toHaveBeenCalled();
        });

    });

});
