$(function() {

  $("#accept-privacy").click(function() {
    // redirect, this will be caught by the app to handle and accept state
    window.location.href = 'tzukuri://privacy-accept';
  });

  $("#reject-privacy").click(function() {
    // redirect, this will be caught by the app to handle a reject state
    window.location.href = 'tzukuri://privacy-reject';
  });

});
