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
});
