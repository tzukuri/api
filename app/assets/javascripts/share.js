$(function() {
    var url = null;

    $('a.share').click(function(event) {
        var panel = $(this).closest('article');
        $('article.blur').removeClass('blur');
        panel.addClass('blur');

        url = window.location.href.split('#')[0] + '#' + panel[0].id;

        $('#share-panel').css('top', panel.position().top + 60);
        $('#share-panel').css('height', panel.height());
        $('#share-panel').fadeIn();

        event.preventDefault();
    });

    $('#close-share-panel').click(function(event) {
        $('article.blur').removeClass('blur');
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
