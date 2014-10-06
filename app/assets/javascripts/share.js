$(function() {
    var url = null;
    var pairs = false;

    $('a.share').click(function(event) {
        var panel = $(this).closest('article');

        if (panel[0].id == 'whichpair') {
            var panel = $(this).closest('section');
            $('section.blur').removeClass('blur');
            pairs = true
        } else {
            $('article.blur').removeClass('blur');
            pairs = false;
        }

        panel.addClass('blur');

        url = window.location.href.split('#')[0] + '#' + panel[0].id;

        if (pairs)
            $('#share-panel').css('top', panel.position().top + 360);
        else
            $('#share-panel').css('top', panel.position().top + 60);

        $('#share-panel').css('height', panel.height());
        $('#share-panel').css('width', panel.width());
        $('#share-panel').css('margin-left', '-' + (panel.width() / 2) + 'px');
        $('#share-panel').fadeIn();

        event.preventDefault();
    });

    $('#close-share-panel').click(function(event) {
        $('article.blur').removeClass('blur');
        $('section.blur').removeClass('blur');
        $('#share-panel').fadeOut();
        event.preventDefault();
    });

    $('#share-fb').click(function(event) {
        event.preventDefault();
    });

    $('#share-twitter').click(function(event) {
        event.preventDefault();
    });

    $('#share-pinterest').click(function(event) {
        event.preventDefault();
    });

    $('#share-tumblr').click(function(event) {
        event.preventDefault();
    });

    $('#share-email').click(function(event) {
        event.preventDefault();
    });

    $('#share-link').click(function(event) {
        event.preventDefault();
    });
});
