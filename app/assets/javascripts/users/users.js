$(function() {
  if (!$('body').hasClass('sessions') && !$('body').hasClass('passwords') && !$('body').hasClass('unlocks')) return;

  $(document).ready(function(){
    // if there is an error on the form, shake the button
    if ($('#actions').attr('data-error') === 'true') {
      $('#actions').tzAnimate('shake')
    }
  });
});
