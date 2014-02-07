var mod = angular.module( 'coffeetech', [] );

mod.factory( 'Github', function() { // # <1>
    return { create: function(username, password) { 
        return new Github({ username: username, 
                            password: password, 
                            auth: 'basic' }) }
           };
});

mod.factory( 'Geo', [ '$window', function( $window ) { // # <2>
    return $window.navigator.geolocation;
} ] );

mod.factory( 'Prompt', [ '$window', function( $window ) { 
    return { prompt: $window.prompt }; 
} ] );

mod.controller( 'GithubCtrl', [ '$scope', 'Github', 'Geo', 'Prompt', '$timeout', function( $scope, ghs, Geo, Prompt, $timeout ) {
    $scope.messages = []

    $scope.init = function() {
        $scope.getCurrentLocation( function( position ) {
            $scope.latitude = position.coords.latitude;
            $scope.longitude = position.coords.longitude;
            var gh = ghs.create();
            $scope.repo = gh.getRepo( "xrd", "spa.coffeete.ch" ); // # <3>
            $scope.repo.read( "gh-pages", "cities.json", function(err, data) { // # <4>
                $scope.cities = JSON.parse( data ); // # <5>
                // Determine our current city
                $scope.detectCurrentCity(); // # <6>

                // If we have a city, get it
                if( $scope.city ) {
                    $scope.retrieveCity();
                }

                $scope.$apply(); // # <7>
            });
        });
    };

    $scope.retrieveCity = function() {
        $scope.repo.read( "gh-pages", $scope.city.name + ".json", function(err, data) { 
            $scope.shops = JSON.parse( data );
            $scope.$apply();
        });
    }

    $scope.getCurrentLocation = function( cb ) {
        if( undefined != Geo ) {
            Geo.getCurrentPosition( cb, $scope.geolocationError );
        } else {
            console.error('not supported');
        }
        
    };

    $scope.detectCurrentCity = function() {
        // Calculate the distance from our current position and use
        // this to determine which city we are closest to and within
        // 25 miles
        for( var i = 0; i < $scope.cities.length; i++ ) {
            var dist = $scope.calculateDistance( $scope.latitude, $scope.longitude, $scope.cities[i].latitude, $scope.cities[i].longitude );
            if( dist < 25 ) {
                $scope.city = $scope.cities[i];
                break;
            }
        }
    }

    toRad = function(Value) {
        return Value * Math.PI / 180;
    };
    
    $scope.calculateDistance = function( latitude1, longitude1, latitude2, longitude2 ) {
        R = 6371;
        dLatitude = toRad(latitude2 - latitude1);
        dLongitude = toRad(longitude2 - longitude1);
        latitude1 = toRad(latitude1);
        latitude2 = toRad(latitude2);
        a = Math.sin(dLatitude / 2) * Math.sin(dLatitude / 2) + Math.sin(dLongitude / 2) * Math.sin(dLongitude / 2) * Math.cos(latitude1) * Math.cos(latitude2);
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        d = R * c;
        return d;
    }

    $scope.loadCity = function( city ) {
        $scope.repo.read( "gh-pages", city + ".json", function(err, data) { // # <2>
            $scope.shops = JSON.parse( data ); // # <3>
            $scope.$apply();
        });
    }
    
    $scope.geolocationError = function( error ) {
        console.log( "Inside failure" );
    };

    $scope.notifyWaiting = function( state, msg ) {
        if( state ) {
            $scope.waiting = {};
            $scope.waiting.state = state;
            $scope.waiting.msg = msg;
        }
        else {
            $scope.waiting = undefined;
        }
    }

    $scope.appendQuirkToShop = function() {
        if( undefined == $scope.shopToAnnotate.information ) {
            $scope.shopToAnnotate.information = [];
        }
        $scope.shopToAnnotate.information.push( $scope.annotation );
    };

    $scope.annotateAfterForkCompletes = function() {
        $scope.forked_repo.read( "gh-pages", "cities.json", function(err, data) { 
            if( err ) {
                $timeout( $scope.annotateAfterForkCompletes, 10000 );
            }
            else {
                $scope.notifyWaiting( "annotating", "Annotating data on GitHub" );
                // Write the new data into our repository
                $scope.appendQuirkToShop();
                $scope.forked_repo.write('gh-pages', $scope.city + '.json', JSON.stringify( $scope.shops ), 'Added my quirky information', function(err) {
                    if( !err ) {
                        // Annotate our data using a pull request
                        var pull = {
                            title: "Adding quirky information to " + $scope.shopToAnnotate.name,
                            body: "Created by :" + $scope.username,
                            base: "gh-pages",
                            head: $scope.username + ":" + "gh-pages"
                        };
                        $scope.forked_repo.createPullRequest( pull, function( err, pullRequest ) {
                            if( !err ) {
                                $scope.notifyWaiting( "annotated", "Successfully sent annotation request" );
                                $timeout( function() { $scope.notifyWaiting( undefined ) }, 5000 );
                                $scope.$apply();
                            }
                        } );
                    }
                    $scope.$apply();
                });
            }
            $scope.$apply();
        } );
        
        $scope.notifyWaiting( "annotated" );
    };
    
    $scope.annotate = function( shop ) {
        $scope.shopToAnnotate = shop;
        $scope.username = Prompt.prompt( "Enter your github username" )
        pass = Prompt.prompt( "Enter your github password" )
        $scope.annotation = Prompt.prompt( "Enter data to add" );
        gh = ghs.create( $scope.username, pass );
        $scope.forked_repo = gh.getRepo( "xrd", "spa.coffeete.ch" );
        $scope.forked_repo.fork( function( err ) {
            if( !err ) {
                $scope.notifyWaiting( "forking", "Forking in progress on GitHub, please wait" );
                $timeout( $scope.annotateAfterForkCompletes, 10000 );
                $scope.$apply();
            }
        } );

    };
    
} ] );

