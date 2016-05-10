var tzukuri = (function () {
  return {
    modal: modal,
    map: map
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
