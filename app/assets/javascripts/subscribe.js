$(function() {
    $('#show-subscribe').click(function(event) {
        event.preventDefault();
        $('#subscribe-popup').show();
        setTimeout(function() {
            $('#subscribe-popup').removeClass('hidden');
        }, 20);
        $('#blur-content').addClass('blur');
        if ($('html').width() > 720)
            $('#subscribe-form input[type=text]').focus();
    });
            
    $('#subscribe-popup').click(function(event) {
        if($(event.target).closest('#subscribe-form').length == 0) {
            $('#blur-content').removeClass('blur');
            $('#subscribe-popup').addClass('hidden');
            setTimeout(function() {
                $('#subscribe-popup').hide();
                $('#text-container label').show();
                $('#subscribe-status').hide();
                $('#subscribe-form input[type=text]').val('');
                $('#subscribe-form button').hide();
                buttonShowing = false;
            }, 1000);
        }
    });

    var buttonShowing = false;
    $('#subscribe-form input').keyup(function(event) {
        console.log(1);
        if (!buttonShowing) {
            $('#subscribe-form button').fadeIn();
            buttonShowing = true;
        }
    });

    function showSubscribeError(msg) {
        $('#subscribe-status').text(msg);
        $('#text-container label').fadeOut();
        $('#subscribe-status').fadeIn();
    }

    $('#new_email').on('ajax:success', function(e, data, status, xhr) {
        if (data.success) {
            $('#text-container').fadeOut();
            $('#subscribe-form input[type=text]').fadeOut();
            $('#subscribe-form button').addClass('complete');

            setTimeout(function() {
                $('#blur-content').removeClass('blur');
                $('#subscribe-popup').addClass('hidden');
                setTimeout(function() {
                    $('#subscribe-popup').hide();
                    $('#text-container').show();
                    $('#subscribe-form input[type=text]').show();
                    $('#subscribe-form input[type=text]').val('');
                    $('#subscribe-form button').removeClass('complete');
                    $('#text-container label').show();
                    $('#subscribe-status').hide();
                    $('#subscribe-form button').hide();
                    buttonShowing = false;
                }, 1000);
            }, 1300);
        } else {
            showSubscribeError(data.reason);
        }
    }).on('ajax:error', function(e, xhr, status, error) {
        showSubscribeError('Network error, try again.');
    });
});
