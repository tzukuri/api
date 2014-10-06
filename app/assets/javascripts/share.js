$(function() {
    var url = null;
    var pairs = false;
    var DEFAULT_TEXT = 'Meet+the+world%27s+first+unloseable+sunglasses';
    var DEFAULT_IMAGE = encodeURIComponent('http://tzukuri.com/share_image.jpg');

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
            $('#share-panel').css('top', panel.position().top + 1850);
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

    function showWindow(url, title) {
        var centre = Math.floor(document.width / 2) - 335;
        var window_left = window.screenX || window.screenLeft;
        var popup_left = window_left + centre; 
        window.open(
            url,
            title,
            'left=' + popup_left + ',top=300,width=670,height=300,toolbar=0,resizable=0'
        );
    }

    $('#share-fb').click(function(event) {
        event.preventDefault();
        showWindow(
            'https://www.facebook.com/sharer.php?app_id=311590038897709&sdk=joey&display=popup&u=http%3A%2F%2Ftzukuri.com%2F', //+ encodeURIComponent(url),
            'Facebook'
        );
    });

    $('#share-twitter').click(function(event) {
        event.preventDefault();
        showWindow(
            'https://twitter.com/intent/tweet?text=' + DEFAULT_TEXT + '&url=' + encodeURIComponent(url),
            'Twitter'
        );
    });

    $('#share-pinterest').click(function(event) {
        event.preventDefault();
        showWindow(
            'http://www.pinterest.com/pin/create/button/?url=' + encodeURIComponent(url) + '&description=' + DEFAULT_TEXT + '&media=' + DEFAULT_IMAGE,
            'Pinterest'
        );
    });

    $('#share-tumblr').click(function(event) {
        event.preventDefault();
        showWindow(
            'https://www.tumblr.com/share/photo?' + DEFAULT_IMAGE + '&caption=' + DEFAULT_TEXT + '&clickthru=' + encodeURIComponent(url),
            'Tumblr'
        );
    });

    $('#share-email').click(function(event) {
        event.preventDefault();
    });

    $('#share-link').click(function(event) {
        event.preventDefault();
    });
});
