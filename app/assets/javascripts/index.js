$(function() {
    if (!$('html').hasClass('index'))
        return;

    var currentFrames = 'front';
    $('#frames menu div').click(function(event) {
        var option = $(this);
        var newFrames = option.attr('data-image');

        $('#frames ul img.' + currentFrames).css('opacity', 0);
        $('#frames ul img.' + newFrames).css('opacity', 1);
        currentFrames = newFrames;

        $('#frames menu div').removeClass('selected');
        option.addClass('selected');
        event.preventDefault();
    });

    countdown(
        // number of milliseconds since Unix epoch UTC. required since new Date() returns local time.
        // js date measures months from 0, so 8 == September. hours adjusted for EST summer time (UTC -4)
        Date.UTC(2014, 8, 19, 4),
        function(ts) {
            $('#countdown-days').text(ts.days);
            $('#countdown-hours').text(ts.hours);
            $('#countdown-minutes').text(ts.minutes);
            $('#countdown-seconds').text(ts.seconds);
        },
        countdown.DEFAULTS // trigger callback roughly once per second
    );
});
