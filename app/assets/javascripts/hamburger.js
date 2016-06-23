$(function() {
  $('#hamburger').on('click', function(e) {
    e.preventDefault();
    $('header menu').toggleClass('showing');
  })
});
