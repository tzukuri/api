$(function() {
    if (!$('body').hasClass('design'))
        return;

    $('#ive-optical-toggle').on('click', function() {
        $('#ive-sun').fadeOut(function() {
            $('#ive-optical').fadeIn()
        })

        $('#ive-optical-toggle').addClass('selected')
        $('#ive-sun-toggle').removeClass('selected')
    })

    $('#ive-sun-toggle').on('click', function() {
        $('#ive-optical').fadeOut(function() {
            $('#ive-sun').fadeIn()
        })

        $('#ive-sun-toggle').addClass('selected')
        $('#ive-optical-toggle').removeClass('selected')
    })

    $('#ford-optical-toggle').on('click', function() {
        $('#ford-sun').fadeOut(function() {
            $('#ford-optical').fadeIn()
        })

        $('#ford-optical-toggle').addClass('selected')
        $('#ford-sun-toggle').removeClass('selected')
    })

    $('#ford-sun-toggle').on('click', function() {
        $('#ford-optical').fadeOut(function() {
            $('#ford-sun').fadeIn()
        })

        $('#ford-sun-toggle').addClass('selected')
        $('#ford-optical-toggle').removeClass('selected')
    })
});
