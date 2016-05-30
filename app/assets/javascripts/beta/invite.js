$(function() {
    if (!$('body').hasClass('beta')) return;

    // -----------------------------
    // on page load binding
    // -----------------------------
    $(document).on("tzukuri.page.load", function() {
        // invite
        if ($('#beta-invite').attr('data-error')) {
            $('#form-error').tzAnimate('shake')
        }
    })

    $('#new_beta_user').on('input', function() {
        var complete = true;

        $(this).children("input").each(function(e) {
            if ($(this).val() === "") {
                return complete = false;
            }
        })

        if (complete && !$("#register-btn").is(":visible")) {
            // show the submit button
            $("#register-btn").tzAnimate('bounceIn').show();
        }
    })

});
