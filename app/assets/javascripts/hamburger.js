$('#hamburger').on('click', function(event) {
  event.preventDefault();

  var nav = $('#primary-nav')

  if (nav.css('visibility') == 'visible') {
    $('#hamburger').removeClass('fa-times').addClass('fa-bars')
    nav.removeClass('shown')
  } else {
    $('#hamburger').removeClass('fa-bars').addClass('fa-times')
    nav.addClass('shown')
  }

})
