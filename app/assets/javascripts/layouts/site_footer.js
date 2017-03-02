$(function() {
  $("#subForm").on('submit', function(e) {
    // track leads in fq and ga when users register for the mailing list
    fbq('track', 'Lead');
    ga('send', 'event', 'mailing-list', 'register');
  })
});
