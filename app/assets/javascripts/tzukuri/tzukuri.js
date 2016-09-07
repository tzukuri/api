// loaded from their respective files
var tzukuri = (function () {
  return {
    modal: modal,
    map: map,
    models: models
  }
}())

// -----------------------
// tzukuri events
// -----------------------

// tzukuri.page.load
var tzukuriLoad = function() {
  $.event.trigger({
    type:    "tzukuri.page.load"
  });
}

$(document).ready(tzukuriLoad);
$(document).on('page:load', tzukuriLoad);

// -----------------------------
// javascript extensions
// -----------------------------
$.fn.extend({
    // easily add and remove animate.css animation classes
    tzAnimate: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $(this).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).removeClass('animated ' + animationName);
        });
        return $(this);
    }
});
