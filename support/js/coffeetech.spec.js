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

    function generateMockRepositorySupport() {
        repo = { read: function( branch, filename, cb ) {
            cb( undefined, JSON.stringify( filename == "cities.json" ? CITIES : PORTLAND ) );
        } };
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
            scope = $rootScope.$new();
            ctrl = $controller( "GithubCtrl", { $scope: scope, Github: gh, Geo: geo } );
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
    

    // describe( "#getRepos", function() {
    //     it( "should get the repository contents", function() {
    //         scope.init();
    //         expect( gh.getRepo ).toHaveBeenCalled();
    //         expect( repo.read ).toHaveBeenCalled();
    //         expect( scope.cities[0].name ).toEqual( "portland" );
    //     });
    // });

    // describe( "#getCity", function() {
    //     var geo = undefined;
    //     var window = undefined;

    //     describe( "#portland", function() {
    //         beforeEach( inject( function( $controller, $rootScope ) {
    //             window =generateMockGeolocationSupport();
    //             ctrl = $controller( "GithubCtrl", { $scope: scope
    //                                                 , Github: gh
    //                                                 , $window: window
    //                                               } );
    //         } ) );
            
    //         it( "should find out if a city matches", function() {
    //             scope.init();
    //             scope.getCurrentLocation();
    //             expect( geo.getCurrentPosition ).toHaveBeenCalled();
    //             scope.detectCurrentCity();
    //             expect( scope.city.name ).toEqual( "portland" );
    //         });

    //     });

    //     describe( "#seattle", function() {
    //         beforeEach( inject( function( $controller, $rootScope ) {
    //             window =generateMockGeolocationSupport();
    //             ctrl = $controller( "GithubCtrl", { $scope: scope
    //                                                 , Github: gh
    //                                                 , $window: window
    //                                               } );
    //         } ) );
            
    //         it( "should find out if a city matches", function() {
    //             scope.init();
    //             scope.getCurrentLocation();
    //             expect( geo.getCurrentPosition ).toHaveBeenCalled();
    //             scope.detectCurrentCity();
    //             expect( scope.city.name ).toEqual( "seattle" );
    //         });
            
    //     });

    //     describe( "#notfound", function() {
    //         beforeEach( inject( function( $controller, $rootScope ) {
    //             window =generateMockGeolocationSupport( 50, 100 );
    //             ctrl = $controller( "GithubCtrl", { $scope: scope
    //                                                 , Github: gh
    //                                                 , $window: window
    //                                               } );
    //         } ) );
            
    //         it( "should find out if a city matches", function() {
    //             scope.init();
    //             scope.getCurrentLocation();
    //             expect( geo.getCurrentPosition ).toHaveBeenCalled();
    //             scope.detectCurrentCity();
    //             expect( scope.city ).toEqual( undefined );
    //         });
            
    //     });
//});
});
