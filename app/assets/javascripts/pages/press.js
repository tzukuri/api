// when onLoad event fires (all resources ready and page is (or should be) laid out)
$(window).load(function() {
    // if the user clicked through to a specific article, scroll to the article,
    // but offset for the header (the browser will scroll the top of the article
    // underneath the header i.e at 0px otherwise)
    var article = $(window.location.hash);
    if (article.length != 0) {
        var offset = article.offset();
        if (offset && offset.top) {
            var scroll = offset.top;
            scroll -= 85; // header: 65px, + padding: 20px

            // delay scrolling so we can override the browser's own scrolling behaviour
            // (it will scroll the element but won't offset the header)
            setTimeout(function() {
                $(window).scrollTop(scroll);
            }, 100);
        }
    }
});


$(function() {
    $('.continue a').click(function(e) {
        var link = $(this);
        var parent = link.closest('.continue');
        var article = parent.closest('.article');
        var section = article.find('section.bottom');

        // prevent scrolling to the top of the page
        e.preventDefault();

        // show the 'bottom' (expanded) content
        section.show();

        // hide the p element containing the link
        parent.hide();
    });
});
