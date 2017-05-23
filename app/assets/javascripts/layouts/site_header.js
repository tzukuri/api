function checkScrollState() {
    if($(window).scrollTop() > 18) {
        $('header').addClass('scrolling');
    } else {
        $('header').removeClass('scrolling');
    }
}

// the page may load at a certain scroll position (e.g after a reload)
// so set the correct scroll state on page load
$(window).load(function() {
    // move our fn call to the end of the event queue to give the browser
    // time to run its own scroll processing (e.g scrolling to # anchors)
    setTimeout(checkScrollState, 200);
});

$(function() {
    // whenever the window scrolls update the header scroll state
    $(window).scroll(checkScrollState);

    // whenever the window resizes the scroll position might change
    $(window).resize(checkScrollState);
});
