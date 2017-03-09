var DEFAULT_ERROR_TEXT = "an unexpected error occurred. please try submitting again or contact us for help.";

function showStatus(title, text) {
    var status = $('#cant-decide-status section');
    status.find('h1').text(title);
    status.find('h2').text(text);
    
    setTimeout(function() {
        status.css('display', 'inline-block');
    }, 10);

    setTimeout(function() {
        status.removeClass('hidden');
    }, 40);
}

$(function() {
    $('#cant-decide form').on('submit', function() {
        // show the status panel above the form during submission to prevent
        // re-clicks and indicate the form is being submitted
        setTimeout(function() {
            $('#cant-decide-status').show();
        }, 10);

        setTimeout(function() {
            $('#cant-decide-status').removeClass('hidden');
        }, 40);
    });

    $('#cant-decide').on('ajax:success', function(e, data, status, xhr) {
        if ((data != null) && (data.success == true)) {
            showStatus('thanks', "we'll be in touch asap to see how we can help");
        } else {
            var text = DEFAULT_ERROR_TEXT;
            if (data.reason != null)
                text = data.reason;
            showStatus('sorry', text);
        }
    });

    $('#cant-decide').on('ajax:error', function(e, xhr, status, error) {
        showStatus('sorry', DEFAULT_ERROR_TEXT);
    });

    $('#close-cant-decide-status').on('click', function(e) {
        e.preventDefault();

        // fade out animation is 0.6s
        $('#cant-decide-status').addClass('hidden');

        setTimeout(function() {
            // hide the status layer to allow clicks to underlying elements
            $('#cant-decide-status').hide();

            // hide the status text so it can be transitioned in again
            $('#cant-decide-status section').hide();
            $('#cant-decide-status section').addClass('hidden');
        }, 1000);
    });
});
