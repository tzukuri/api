$(function() {
    var url = null;
    var pairs = false;
    var DEFAULT_TEXT = 'Meet%20the%20world%27s%20first%20unloseable%20sunglasses';
    var DEFAULT_IMAGE = encodeURIComponent('http://tzukuri.com/share_image.jpg');

    window.setShareURL = function(newURL) {
        url = newURL;
    }

    $('a.share').click(function(event) {
        var panel = $(this).closest('article');
        event.preventDefault();

        if (panel[0].id == 'whichpair') {
            var panel = $(this).closest('section');
            $('section.blur').removeClass('blur');
            pairs = true
        } else {
            $('article.blur').removeClass('blur');
            pairs = false;
        }

        panel.addClass('blur');

        if (panel.attr('data-url'))
            url = panel.attr('data-url');
        else
            url = window.location.href.split('#')[0] + '#' + panel[0].id;

        if (pairs)
            $('#share-panel').css('top', panel.position().top + 1600);
        else
            $('#share-panel').css('top', panel.position().top + 60);
        
        $('#share-panel').css('height', panel.height());
        $('#share-panel').css('width', panel.width());
        $('#share-panel').css('margin-left', '-' + (panel.width() / 2) + 'px');
        $('#share-panel').fadeIn();
    });

    function closeSharePanel() {
        $('article.blur').removeClass('blur');
        $('section.blur').removeClass('blur');
        $('#share-panel').fadeOut();
        setTimeout(function() {
            $('#share-copy').hide();
        }, 1000);
    }

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

    $('#close-share-panel').click(function(event) {
        closeSharePanel();
        event.preventDefault();
    });

    $('#share-fb').click(function(event) {
        showWindow(
            'https://www.facebook.com/sharer.php?app_id=311590038897709&sdk=joey&display=popup&u=' + encodeURIComponent(url),
            'Facebook'
        );
        event.preventDefault();
        closeSharePanel();
    });

    $('#share-twitter').click(function(event) {
        showWindow(
            'https://twitter.com/intent/tweet?text=' + DEFAULT_TEXT + '&url=' + encodeURIComponent(url),
            'Twitter'
        );
        event.preventDefault();
        closeSharePanel();
    });

    $('#share-pinterest').click(function(event) {
        showWindow(
            'http://www.pinterest.com/pin/create/button/?url=' + encodeURIComponent(url) + '&description=' + DEFAULT_TEXT + '&media=' + DEFAULT_IMAGE,
            'Pinterest'
        );
        event.preventDefault();
        closeSharePanel();
    });

    $('#share-tumblr').click(function(event) {
        showWindow(
            'https://www.tumblr.com/share/photo?' + DEFAULT_IMAGE + '&caption=' + DEFAULT_TEXT + '&clickthru=' + encodeURIComponent(url),
            'Tumblr'
        );
        event.preventDefault();
        closeSharePanel();
    });

    $('#share-email').click(function(event) {
        window.location = 'mailto:?subject=' + DEFAULT_TEXT + '&body=' + encodeURIComponent(url);
        event.preventDefault();
        closeSharePanel();
    });

    $('#share-link').click(function(event) {
        event.preventDefault();
        $('#share-copy').val(url);
        $('#share-copy').show();
    });
});
