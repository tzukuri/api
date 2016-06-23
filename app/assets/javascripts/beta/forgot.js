$(function() {
    if (!$('body').hasClass('beta')) return;

    // show the continue button to login when the user begins typing
    $('#email').on('input', function(e) {
        if ($(this).val().length > 0 && !$("#submit-btn").is(":visible")) {
            $("#submit-btn").tzAnimate('bounceIn').show()
        }
    })

    $('#beta_user_retrieve').on('ajax:success', function(e, data) {
        if (data.success) {
            $("#submit-btn").fadeOut(function() {
                $("#email-confirm").html('If a matching account was found an email was sent with your login link').fadeIn();
                $("#email").prop('disabled', true);
            });
        }
    }).on('ajax:error', function(e, data) {
        // todo: handle the error state
        console.log(data)
    });

    $('#beta_user_retrieve').on('submit', function(e) {
        $('#submit-btn').hide();
        $('#email-confirm').show();
    });

});
