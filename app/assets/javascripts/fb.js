$(document).ready(function() {
  $.ajaxSetup({ cache: true });
  $.getScript('//connect.facebook.net/en_US/sdk.js', function(){
    FB.init({
      appId      : '311590038897709',
      xfbml      : true,
      version    : 'v2.9'
    });
    FB.AppEvents.logPageView();
  });
});
