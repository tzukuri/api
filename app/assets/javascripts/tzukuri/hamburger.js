//= require slideout.min

var hamburger = (function () {
  var h = {}

  h.init = function() {
    // set up the slideout object
    var slideout = new Slideout({
      'panel': document.getElementById('panel'),
      'menu': document.getElementById('menu'),
      'padding': 256,
      'tolerance': 70
    });

    // toggle the slideout when hamburger is tapped
    $("#hamburger").on('click', function(event) {
      slideout.toggle();
    })

    var fixed = document.querySelector('.fixed-header');

    slideout.on('translate', function(translated) {
      fixed.style.transform = 'translateX(' + translated + 'px)';
    });

    slideout.on('beforeopen', function () {
      fixed.style.transition = 'transform 300ms ease';
      fixed.style.transform = 'translateX(256px)';
    });

    slideout.on('beforeclose', function () {
      fixed.style.transition = 'transform 300ms ease';
      fixed.style.transform = 'translateX(0px)';
    });

    slideout.on('open', function () {
      fixed.style.transition = '';
    });

    slideout.on('close', function () {
      fixed.style.transition = '';
    });
  }

  return h;
});
