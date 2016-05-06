$(function() {
    $('#hamburger').click(function(event) {
        event.preventDefault();
        $('header menu').toggleClass('showing');
    });
});