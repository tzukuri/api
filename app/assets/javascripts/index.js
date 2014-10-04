$(function() {
    if (!$('html').hasClass('index'))
        return;

    var currentFrames = 'front';
    $('#frames menu div').click(function(event) {
        var option = $(this);
        var newFrames = option.attr('data-image');

        $('#frames ul img.' + currentFrames).fadeOut();
        $('#frames ul img.' + newFrames).fadeIn();
        currentFrames = newFrames;

        $('#frames menu div').removeClass('selected');
        option.addClass('selected');
        event.preventDefault();
    });
});
