$(function() {
    if (!$('body').hasClass('beta')) return;

    // show the continue button to login when the user begins typing
    $('#email').on('input', function(e) {
        if ($(this).val().length > 0 && !$("#submit-btn").is(":visible")) {
            $("#submit-btn").tzAnimate('bounceIn').show()
        }
    })

    // creating a new response to a survey question
    $('#beta_user_retrieve').on('ajax:success', function(e, data) {
        console.log(data)
        if (data.success) {

          $("#sent-email").html(data.email)

          $("#submit-btn").fadeOut(function() {
            $("#email-confirm").fadeIn();
            $("#email").prop('disabled', true);
          });
        }
    }).on('ajax:error', function(e, data) {
        // todo: handle the error state
    });

});
