// bind subscribe click
$(document).on("click", "#show-subscribe", function() {
    tzukuri.modal.show({
        modal: "#subscription-modal",
        tint: "light",
        dismissable: true
    });
})

$(function() {
    $('#new_email').on('ajax:success', function(e, data, status, xhr) {
        if (data.success) {
            $("#subscribe-status").removeClass("error").addClass("success").text("Thanks for subscribing!")
            $("#subscribe-status").fadeIn();

            setTimeout(function(){
                tzukuri.modal.hideAll();

                // clear form
                $("#subscribe-status").hide()
                $("#email_email").val("")
            }, 1500);
        } else {
            $("#subscribe-status").addClass("error").text(data.reason)
            $("#subscribe-status").fadeIn();
        }
    }).on('ajax:error', function(e, xhr, status, error) {
        $("#subscribe-error").text("Network error, try again")
    });
})

