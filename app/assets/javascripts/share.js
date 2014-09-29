$(function() {
    $('a.share').click(function(event) {
        var panel = $(this).closest('article');
        panel.addClass('blur');

        var url = window.location.href.split('#')[0] + '#' + panel[0].id;

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
});
