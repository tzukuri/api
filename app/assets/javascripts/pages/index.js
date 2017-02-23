$(function() {
    if (!$('body').hasClass('index'))
        return;

    // reference to the crossfader object
    var screenshotFade;
    var textFade;

    // $('#new_interest').submit(function() {
    //     $('#new_interest input').removeClass('error')
    //
    //     if ($('#interest_email').val() == 'friends@tzukuri.com') {
    //       console.log('SHOWING RESERVATION')
    //       // window.location('reserve')
    //       window.location.href = "reserve";
    //     }
    //
    //     $("#interest-submit").hide()
    // })
    //
    // $('#new_interest').on('ajax:success', function(e, data) {
    //         if (data.success) {
    //             // track a registered lead on facebook pixel
    //             fbq('track', 'Lead');
    //
    //             $("#messages").removeClass('tz-error').html("Thanks for registering! We'll be in touch soon.")
    //
    //             setTimeout(function() {
    //                 tzukuri.modal.hideAll()
    //
    //                 $("#new_interest")[0].reset()
    //                 $("#messages").html("")
    //                 $("#interest-submit").show()
    //             }, 1800)
    //         } else {
    //             $("#interest-submit").show()
    //
    //             var errors = data.errors
    //             var fullErrors = data.full_errors
    //
    //             // add error classes
    //             for (var key in errors) {
    //                 $('#new_interest input#interest_' + key).addClass('error')
    //             }
    //
    //             $("#messages").addClass('tz-error').html(data.full_errors.join(', '))
    //
    //             $("#interest-submit").tzAnimate('shake')
    //         }
    // }).on('ajax:error', function(e, data) {
    //     $("#errors").html('An error has occurred, please try again.')
    // });

    $(document).on("ready", function() {
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

    $('#register-interest').on('click', function() {
        tzukuri.modal.show({
            modal: "#register-interest-modal",
            tint: "light",
            dismissable: true
        })
    })

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
