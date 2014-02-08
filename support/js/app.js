var everyauth = require('everyauth')
  , express = require('express');

if( !process.env['GITHUB_CLIENT_ID'] ||
    !process.env[ 'GITHUB_CLIENT_SECRET' ] ) {
    console.log( "Need both GITHUB_CLIENT_SECRET and GITHUB_CLIENT_ID specified as env vars" );
    process.exit( -1 );
}


var nextUserId = 0;
var usersById = {};

function addUser (source, sourceUser) {
  var user;
  if (arguments.length === 1) { // password-based
    user = sourceUser = source;
    user.id = ++nextUserId;
    return usersById[nextUserId] = user;
  } else { // non-password-based
    user = usersById[++nextUserId] = {id: nextUserId};
    user[source] = sourceUser;
  }
  return user;
}

everyauth.everymodule
    .findUserById( function (id, callback) {
        console.log( "Whatever...", id );
        callback(null, usersById[id]);
    });

everyauth.github
    .appId( process.env['GITHUB_CLIENT_ID'] )
    .appSecret( process.env[ 'GITHUB_CLIENT_SECRET' ] )
    .findOrCreateUser( function (session, 
                                 accessToken, 
                                 accessTokenExtra, 
                                 ghud ) {
        console.log( "In here", ghud );
        return usersById[ghud.id] ||
            (usersById[ghud.id] = addUser('facebook', ghud));
    })
    .scope( [ 'user', 'repo' ] )
    .redirectPath('/');


var app = express();

app.get( "/token.json", function( req, res ) {
    res.setHeader( "Content-type", "application/json" );
    console.log( "Session", req.session );
    console.log( "User", req.user );
    console.log( "EA User", everyauth.user );
    res.end( "Hi" ); // "<script>var AUTH_TOKEN = '" + req.session['token'] + "'</script>" );
} );

app.get( "/", function( req, res ) {
    console.log( "Session", req.session );
    console.log( "User", req.user );
    res.end( "Hi there" );
});

app.use( express.bodyParser() )
app.use( express.cookieParser() )
app.use( express.session({secret: 'roasdadadaddckingit'} ) );
app.use( everyauth.middleware() )
app.listen( 3000 )
