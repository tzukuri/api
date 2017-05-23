// loaded from their respective files
var tzukuri = (function () {
  return {
    // takes a container containing images and slowly fades between them
    crossfade: crossfade,
    // set up events to support hamburger menu on mobile
    hamburger: hamburger(),
    // tracking for ga/fb
    tracking: tracking()
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

  // initialisations
  tzukuri.tracking.init()
  tzukuri.hamburger.init()
}

$(document).ready(tzukuriLoad);

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

// extract parameters from the URL
$.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}
