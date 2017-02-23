var tracking = (function () {
  var t = {}

  t.init = function() {
    $(".tz-track").on("click", function(e) {
      var target = $(e.target)
      var category = target.attr('data-category')
      var eventName = target.attr('data-event')

      // send a click event to google analytics with the given category and event
      ga('send', 'event', category, eventName);
    })
  }

  return t;
});
