var tracking = (function () {
  var t = {}

  t.init = function() {

    // bind a click event to tz-track elements and send an event to ga
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
