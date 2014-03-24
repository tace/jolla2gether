
//
// Custom javascript to executein webview. Picks userId field from together.jolla.com
// site.
// First href in the userToolsNav element should return either
//     "/account/signin/?next=/"    (not logged in)
// or
//     "/users/497/tace/"           (logged in)
//
// So this function returns userId number (e.g. 497) or "signin" string.
function get_userId_script()
{
    return "(function() { \
    var userElem = document.getElementById('userToolsNav'); \
    var firstHref = userElem.getElementsByTagName('a')[0].getAttribute('href'); \
    return firstHref.split('/')[2]; \
    })()"
}

function get_userId_script_result_handler(onReadyClosure) {
    return function(result) {
        console.log( "Got userId: " + result );
        onReadyClosure(result)
    }
}
