(function() {
    var script = document.createElement("script");
    script.src = "http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js";
    script.onload = script.onreadystatechange = function(){
        var toc = document.createElement("script");
        toc.src = "toc.js";
        toc.onload = script.onreadystatechange = function(){}
        document.body.appendChild( toc );
    }
    document.body.appendChild( script );
})()


// setTimeout( function() {



// console.log( "Hmm, OK" );
// document.body.innerHTML = '<script type="text/javascript" src="http://code.jquery.com/jquery-2.0.3.min.js"></script>' + document.body.innerHTML;
// document.body.innerHTML = '<script type="text/javascript" src="toc.js"></script>' + document.body.innerHTML;
// console.log( "Yeah, we got here" );
// }, 3000 );

