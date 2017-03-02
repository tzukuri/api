$(window).scroll(_.debounce(function(event){
  $(".action-bar").addClass('hidden')
}, 100, { 'leading': true, 'trailing': false }));

$(window).scroll(_.debounce(function(event){

  if ((window.innerHeight + window.pageYOffset) >= document.body.offsetHeight) {
    // at the bottom of the page, so don't show the action bar
  } else {
    $(".action-bar").removeClass('hidden')
  }

}, 600));
