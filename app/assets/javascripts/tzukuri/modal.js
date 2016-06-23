var container = ".tzukuri-modal";
var dialog = ".modal-dialog"

var modal = (function () {
  var m = {}
  var inner = null;

  /**
   * [show shows a modal]
   * @param  {[type]} args [description]
   * @return {[type]}      [the javascript object of the modal that was shown]
   */
  m.show = function (args) {
    var tint = args.tint
    var dismissable = args.dismissable

    // find the modal on the DOM
    var outer = $(container);
    inner = $(args.modal);

    if (inner.length) {
      if (tint != "dark" && tint != "light") {
        console.warn("Color: " + tint + " is invalid. Expected 'dark' or 'light'")
      } else {
        $(container).removeClass().addClass("tzukuri-modal");
        outer.addClass(tint);
      }

      // set the colour of the outer div
      outer.removeClass("hidden")
      inner.removeClass("hidden")

      // prevent scroll events falling through to the body
      $('body').css('overflow', 'hidden');
    } else {
      console.error("Element: " + args.modal + " could not be found in the DOM")
      return;
    }

    if (dismissable) {
      // bind to dismiss
      $(outer).click(function(e) {
        modal.hideAll()
      })

      $(inner).click(function(e) {
        e.stopPropagation();
      })
    }

    return inner;
  };

  /**
   * [hideAll hides any modal that is currently open as well as the modal overlay]
   */
  m.hideAll = function() {
    $(container).removeClass().addClass("tzukuri-modal hidden");
    $(container).unbind('click');

    // allow scroll events on body again
    $('body').css('overflow', 'auto');

    // hide the dialog
    inner.addClass("hidden");
    inner.unbind('click');
  }

  return m;
}());
