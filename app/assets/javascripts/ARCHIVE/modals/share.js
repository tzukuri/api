$(document).on('tzukuri.page.load', function() {
    var url = null;
    var pairs = false;
    var DEFAULT_TEXT = 'Meet%20the%20world%27s%20first%20unloseable%20sunglasses';
    var DEFAULT_IMAGE = encodeURIComponent('http://tzukuri.com/share_image.jpg');

    // bind showing modal to show-subscribe
    $('a.share').click(function(event) {
        tzukuri.modal.show({
            modal: "#share-modal",
            tint: "light",
            dismissable: true
        });
    })

    $('#close-share-panel').click(function(event) {
        tzukuri.modal.hideAll()
        event.preventDefault();
    });

    $('#share-fb').click(function(event) {
        showWindow(
            'https://www.facebook.com/sharer.php?app_id=311590038897709&sdk=joey&display=popup&u=' + encodeURIComponent(url),
            'Facebook'
        );
        event.preventDefault();
        tzukuri.modal.hideAll()
    });

    $('#share-twitter').click(function(event) {
        showWindow(
            'https://twitter.com/intent/tweet?text=' + DEFAULT_TEXT + '&url=' + encodeURIComponent(url),
            'Twitter'
        );
        event.preventDefault();
        tzukuri.modal.hideAll()
    });

    $('#share-pinterest').click(function(event) {
        showWindow(
            'http://www.pinterest.com/pin/create/button/?url=' + encodeURIComponent(url) + '&description=' + DEFAULT_TEXT + '&media=' + DEFAULT_IMAGE,
            'Pinterest'
        );
        event.preventDefault();
        tzukuri.modal.hideAll()
    });

    $('#share-tumblr').click(function(event) {
        showWindow(
            'https://www.tumblr.com/share/photo?' + DEFAULT_IMAGE + '&caption=' + DEFAULT_TEXT + '&clickthru=' + encodeURIComponent(url),
            'Tumblr'
        );
        event.preventDefault();
        tzukuri.modal.hideAll()
    });

    $('#share-email').click(function(event) {
        window.location = 'mailto:?subject=' + DEFAULT_TEXT + '&body=' + encodeURIComponent(url);
        event.preventDefault();
        tzukuri.modal.hideAll()
    });

    $('#share-link').click(function(event) {
        event.preventDefault();
        $('#share-copy').val(url);
        $('#share-copy').show();
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

});
