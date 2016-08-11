$(function() {
  if (!$('body').hasClass('sessions')) return;

  $(document).ready(function(){
    // if there is an error on the form, shake the button
    if ($('#login').attr('data-error') === 'true') {
      $('#login').tzAnimate('shake')
    }
  });


});
