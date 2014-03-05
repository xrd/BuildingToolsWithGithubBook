var toc = false;
var lookup = {};

$(document).ready( function() {
    $('body').prepend( "<button class='toc' style='position: fixed; top: 10px; left: 10px;'>Toggle TOC Mode</button>" );
    console.log( "Inside the ready event" );
    $('.toc').click( function() {
        console.log( "Got the click event" );
        toc = !toc;
        jQuery.each( [ '.paragraph', '.dlist', '.ulist', '.listingblock', '.colist', '.imageblock', '.admonitionblock' ], function( index, item ) {
            $(item)[toc?'hide':'show']();
            } );

        for( var index = 1; index < 7; index++ ) {
            jQuery( 'h' + index ).click( function( item ) {
                var hideOrShow = lookup[item.target] = !lookup[item.target];
                jQuery( item.target ).siblings()[hideOrShow?'show':'hide']();
            } );
        }
        return true;
    });
});
