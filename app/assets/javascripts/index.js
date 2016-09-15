$(function() {
    if (!$('body').hasClass('index'))
        return;

    // reference to the crossfader object
    var screenshotFade;
    var textFade;

    $(document).on("tzukuri.page.load", function() {
        // fade in the main view, set a small timeout to give the page time to render
        // fixme: remove the timeout
        $('#hero').removeClass('hidden')
        $('#scroll-indicator').removeClass('hidden')

        // setup a crossfader for the screenshots and text
        screenshotFade = tzukuri.crossfade('#screenshot-container', 'img')
        textFade = tzukuri.crossfade('#feature-container', '.app-feature')

        // start the crossfaders
        screenshotFade.start()
        textFade.start()
    });

    $(window).scroll(function(event) {
        $('#scroll-indicator').addClass('hidden')
    });

    // watch for the start of the crossfade animation
    $('#screenshot-container').on('tzukuri.crossfade.fadeStart', function(event, fromIndex, toIndex) {
        $($('#app-nav i')[fromIndex]).removeClass('current')
        $($('#app-nav i')[toIndex]).addClass('current')
    })

    $('#app-prev').on('click', function(event) {
        event.preventDefault()

        // force the crossfaders to navigate
        screenshotFade.previous()
        textFade.previous()
    })

    $('#app-next').on('click', function(event) {
        event.preventDefault()

        // force the crossfaders to navigate
        screenshotFade.next()
        textFade.next()
    })
});
