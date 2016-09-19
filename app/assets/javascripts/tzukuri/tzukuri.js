// loaded from their respective files
var tzukuri = (function () {
  return {
    // contains API for interacting with tzukuri modals
    modal: modal,
    // fixme: currently broken, but should implement an API that gives us access to a map
    map: map,
    // contains all the sizing details, etc. for each model of tzukuri
    models: models,
    // contains all the pricing information for different models
    pricing: pricing,
    // takes a container containing images and slowly fades between them
    crossfade: crossfade
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
